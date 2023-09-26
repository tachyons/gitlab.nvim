local globals = require('gitlab.globals')
local statusline = require('gitlab.statusline')
local utils = require('gitlab.utils')

local function lsp_user_data(item)
  local user_data = item and item.user_data
  if user_data then
    return user_data.nvim and user_data.nvim.lsp
  end
end

local function suggestion_data_from_completion_item(item)
  local lsp = lsp_user_data(item)
  if lsp and lsp.completion_item then
    return lsp.completion_item.data
  end
end

local CodeSuggestionsCommands = {}

--{{{[CodeSuggestionsCommands]
function CodeSuggestionsCommands.new(options)
  vim.validate({
    ['options.auth'] = { options.auth, 'table' },
    ['options.group'] = { options.group, 'number' },
    ['options.lsp_server'] = { options.lsp_server, 'table' },
    ['options.workspace'] = { options.workspace, 'table' },
  })

  local instance = vim.deepcopy(options)
  setmetatable(instance, {
    __index = CodeSuggestionsCommands,
  })
  return instance
end

-- Install the @gitlab-org/gitlab-lsp node module from the GitLab Package Registry into lsp/ under the plugin root.
-- The lsp/ directory includes package.json and package-lock.json files which can be used to enforce version constraints
-- and perform security scans.
--
-- This function may modify package.json/package-lock.json if the environment differs.
function CodeSuggestionsCommands:install_language_server()
  local package = '@gitlab-org/gitlab-lsp'
  local ok = self.lsp_server:is_installed()
  if ok then
    vim.notify(package .. ' already installed.')
    statusline.update_status_line(globals.GCS_INSTALLED)
  end

  if vim.fn.exepath('npm') == '' then
    vim.notify(
      'gitlab.vim: Unsatisfied dependency "npm". Unable to find "npm" in PATH.',
      vim.log.levels.ERROR
    )
    return
  end

  local lsp_path = vim.fn.join({ require('gitlab').plugin_root(), 'lsp' }, '/')

  if vim.fn.isdirectory(lsp_path) == 0 then
    vim.notify('gitlab.vim: Invalid LSP installation directory: ' .. lsp_path, vim.log.levels.ERROR)
    return
  end

  vim.notify('gitlab.vim: Installing ' .. package .. ' to ' .. lsp_path .. '')

  local job_opts = { cwd = lsp_path }
  local cmd = {
    'npm',
    'install',
    package,
    '--userconfig',
    './npmrc',
  }

  local job_id = utils.exec_cmd(cmd, job_opts, function(result)
    if result.exit_code == 0 then
      statusline.update_status_line(globals.GCS_UPDATED)
      vim.notify('gitlab.vim: Successfully installed @gitlab-org/gitlab-lsp')
      return
    end

    vim.notify(
      'gitlab.vim: Unable to install @gitlab-org/gitlab-lsp please install it manually before continuing.',
      vim.log.levels.WARN
    )
  end)

  if job_id > 0 then
    local status = vim.fn.jobwait({ job_id }, 10000)[1]
    if status == 0 then
      statusline.update_status_line(globals.GCS_AVAILABLE_BUT_DISABLED)
      return
    end
  end
end

function CodeSuggestionsCommands:start(options)
  vim.validate({
    ['options.prompt_user'] = { options.prompt_user, 'boolean' },
  })
  statusline.update_status_line(globals.GCS_CHECKING)

  if not self.lsp_server:is_installed() then
    statusline.update_status_line(globals.GCS_UNAVAILABLE)
    vim.notify(
      'Run :GitLabCodeSuggestionsInstallLanguageServer to install the required binary.',
      vim.log.levels.WARN
    )
    return
  end

  local auth = self.auth.resolve({ prompt_user = options.prompt_user })
  if not auth or not auth:token_set() then
    statusline.update_status_line(globals.GCS_UNAVAILABLE)
    -- Invoke :redraw before vim.notify to ensure users will see the warning.
    vim.cmd.redraw()
    vim.notify(
      'gitlab.vim: Run :GitLabCodeSuggestionsStart to interactively authenticate the LSP.',
      vim.log.levels.WARN
    )
    return
  end

  self.lsp_client = require('gitlab.lsp.client').start({
    auth = auth,
    cmd = self.lsp_server:cmd({ args = { '--stdio' } }),
    handlers = require('gitlab.lsp.handlers'),
    workspace = self.workspace,
  })

  if self.lsp_client then
    statusline.update_status_line(globals.GCS_AVAILABLE_AND_ENABLED)
    vim.notify('gitlab.vim: Started Code Suggestions LSP integration.', vim.lsp.log_levels.INFO)
  else
    vim.notify(
      'gitlab.vim: Unable to start LSP try using :GitLabConfigure before reattempting.',
      vim.lsp.log_levels.WARN
    )
  end
end

function CodeSuggestionsCommands:stop()
  if self.lsp_client then
    self.lsp_client.stop()
    self.lsp_client = nil
  else
    vim.notify('gitlab.vim: No active client found.', vim.lsp.log_levels.ERROR)
  end

  statusline.update_status_line(globals.GCS_AVAILABLE_BUT_DISABLED)
end

function CodeSuggestionsCommands:toggle()
  if self.lsp_client then
    vim.notify('gitlab.vim: Toggling Code Suggestions LSP client integration off.')
    self:stop()
  else
    vim.notify('gitlab.vim: Toggling Code Suggestions LSP client integration on.')
    self:start({ prompt_user = true })
  end
end
--}}}

return {
  create = function(options)
    local code_suggestions_commands = CodeSuggestionsCommands.new({
      auth = options.auth,
      group = options.group,
      lsp_server = require('gitlab.lsp.server').new(),
      workspace = options.workspace,
    })
    local suggestion_events = {}

    --{{{[Automatic commands]
    vim.api.nvim_create_autocmd({ 'CompleteDonePre' }, {
      callback = function()
        local config = require('gitlab.config').current()
        if config.language_server.workspace_settings.telemetry.enabled then
          -- complete_info() is only available before CompleteDonePre is complete.
          -- Save the results here since context for rejected suggestions may not make it to
          -- further automatic commands.
          local complete_info = vim.fn.complete_info()
          local items = complete_info and complete_info.items or {}
          local suggestion = suggestion_data_from_completion_item(items[1])
          if suggestion then
            -- Suggestion selected = 0 or the completion item's zero-based index.
            -- No item selected = -1
            --
            -- See also :help complete_info() since the initial state depends on user configuration.
            if complete_info.selected == 0 or complete_info.selected == -1 then
              suggestion_events[suggestion.trackingId] = {
                action = 'suggestion_rejected',
              }
            end
          end
        end
      end,
      group = options.group,
      desc = 'Process completed GitLab Code Suggestions.',
    })

    vim.api.nvim_create_autocmd({ 'CompleteDone' }, {
      callback = function()
        local config = require('gitlab.config').current()
        if config.language_server.workspace_settings.telemetry.enabled then
          -- If v:completed_item event item was set it might be a code suggestion.
          local completed_item = vim.v.completed_item
          if completed_item then
            local suggestion = suggestion_data_from_completion_item(completed_item)
            if suggestion then
              suggestion_events[suggestion.trackingId] = {
                action = 'suggestion_accepted',
              }
            end
          end

          -- Flush suggestion telemetry events upon completion so we can rely on the shortlived
          -- lifecycle to avoid mixups due to strange user cancellation/unrelated completion in the
          -- middle of completing a code suggestion.
          for trackingId, event in pairs(suggestion_events) do
            suggestion_events[trackingId] = nil
            code_suggestions_commands.lsp_client:notify('$/gitlab/telemetry', {
              category = 'code_suggestions',
              action = event.action,
              context = {
                trackingId = trackingId,
              },
            })
          end
        end

        -- This happens outside of insert mode so should be done after we're done with v:completed_item
        if config.code_suggestions.fix_newlines then
          vim.cmd([[s/\%x00/\r/ge]])
        end
      end,
      group = options.group,
      desc = 'Process completed GitLab Code Suggestions.',
    })

    vim.api.nvim_create_autocmd({ 'FileType' }, {
      callback = function()
        local config = require('gitlab.config').current()
        if config.code_suggestions.enabled then
          code_suggestions_commands:start({ prompt_user = false })
        end
      end,
      desc = 'Start Code Suggestions LSP client integration automatically for filetype',
      group = options.group,
      pattern = require('gitlab.config').current().code_suggestions.auto_filetypes,
    })
    --}}}

    --{{{[User-defined commands]
    vim.api.nvim_create_user_command('GitLabCodeSuggestionsInstallLanguageServer', function()
      return code_suggestions_commands:install_language_server()
    end, {
      desc = 'Installs GitLab Language Server package.',
    })
    vim.api.nvim_create_user_command('GitLabCodeSuggestionsStart', function()
      return code_suggestions_commands:start({ prompt_user = true })
    end, {
      desc = 'Starts the Code Suggestions LSP client integration.',
    })
    vim.api.nvim_create_user_command('GitLabCodeSuggestionsStop', function()
      return code_suggestions_commands:stop()
    end, {
      desc = 'Stops the Code Suggestions LSP client integration.',
    })
    --}}}

    --{{{[Keymaps] Defined as <Plug> keymaps to allows users to decide sensible mappings.
    -- :nmap <C-g> <Plug>(GitLabToggleCodeSuggestions)
    vim.keymap.set('n', '<Plug>(GitLabToggleCodeSuggestions)', function()
      return code_suggestions_commands:toggle()
    end, {
      desc = 'Toggle Code Suggestions LSP client integration on/off.',
      noremap = false,
    })
    --}}}
  end,
}

-- vi: set fdm=marker :
