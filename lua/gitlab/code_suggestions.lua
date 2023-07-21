local code_suggestions = {}

local globals = require('gitlab.globals')
local utils = require('gitlab.utils')

local gitlab_language_server_project_api_url = 'https://gitlab.com/api/v4/projects/46261736/'
local gitlab_release_api_url = gitlab_language_server_project_api_url
  .. 'packages/generic/releases/'

function code_suggestions.bootstrap()
  code_suggestions.install_language_server()
  if not code_suggestions.check_personal_access_token() then
    code_suggestions.register_personal_access_token()
    code_suggestions.check_personal_access_token()
  end
end

function code_suggestions.check_personal_access_token()
  if code_suggestions._checked_pat ~= nil then
    return code_suggestions._checked_pat
  end

  code_suggestions.statusline.update_status_line(globals.GCS_CHECKING)

  local token_check_cmd = code_suggestions.token_check_cmd()
  if token_check_cmd == nil then
    code_suggestions.statusline.update_status_line(globals.GCS_UNAVAILABLE)

    return false
  end

  code_suggestions.logging.debug(string.format("Using '%s'", token_check_cmd[1]))

  local out = vim.fn.system(token_check_cmd)
  if vim.v.shell_error == 0 then
    code_suggestions._checked_pat = true
    code_suggestions.statusline.update_status_line(globals.GCS_AVAILABLE_AND_ENABLED)
    return true
  end

  vim.notify(
    string.format('[gitlab.code_suggestions] Output from token check command: %s', tostring(out)),
    vim.log.levels.WARN
  )
  code_suggestions.statusline.update_status_line(globals.GCS_UNAVAILABLE)
  return false
end

function code_suggestions.install_language_server()
  local absolute_path = code_suggestions.lsp_binary_path()
  if absolute_path == '' then
    vim.notify(
      '[gitlab.code_suggestions] Unable to automatically detect lsp_binary_path',
      vim.log.levels.ERROR
    )
    return
  end

  if vim.loop.fs_stat(absolute_path) then
    return
  end

  local binary_name = string.match(absolute_path, '/([^/]+)$')
  if binary_name == nil then
    return
  end

  local lsbinurl = gitlab_release_api_url
    .. code_suggestions.installable_version()
    .. '/'
    .. binary_name
  utils.print('downloading ' .. lsbinurl .. ' to ' .. absolute_path)
  vim.fn.system({
    'curl',
    lsbinurl,
    '--output',
    absolute_path,
  })

  if vim.fn.has('macunix') or vim.fn.has('linux') then
    utils.print('setting ' .. absolute_path .. ' to executable')
    vim.fn.system({
      'chmod',
      '+x',
      absolute_path,
    })
  end

  if vim.fn.has('macunix') then
    utils.print('disabling MacOS quarantine for ' .. absolute_path)
    vim.fn.system({
      'xattr',
      '-d',
      'com.apple.quarantine',
      absolute_path,
    })
  end
end

function code_suggestions.installable_version()
  if code_suggestions.options.language_server_version ~= nil then
    return code_suggestions.options.language_server_version
  end

  local latest_version_list = vim.fn.systemlist({
    '/bin/bash',
    '-c',
    'curl --fail -s -L '
      .. gitlab_language_server_project_api_url
      .. '/releases/permalink/latest | jq -r .name',
  })

  if vim.v.shell_error ~= 0 then
    vim.notify('unable to identify latest version', vim.log.levels.ERROR)
    return
  end

  return latest_version_list[1]
end

function code_suggestions.lsp_binary_path()
  if code_suggestions.options.lsp_binary_path then
    return code_suggestions.options.lsp_binary_path
  end

  local os = utils.current_os()
  local arch = utils.current_arch()

  if os == '' or arch == '' then
    return ''
  end

  local basename = 'gitlab-code-suggestions-language-server-experiment'
  local filename = basename .. '-' .. os .. '-' .. arch

  return string.format('%s/%s', utils.user_data_path(), filename)
end

function code_suggestions.lsp_cmd(subcommand)
  local lsp_binary_path = code_suggestions.lsp_binary_path()

  if lsp_binary_path == '' or not utils.path_exists(lsp_binary_path) then
    local msg = string.format("[gitlab.code_suggestions] '%s' does not exist?", lsp_binary_path)
    vim.notify(msg, vim.log.levels.WARN)
    vim.notify(
      '[gitlab.code_suggestions] Run :GitLabBootstrapCodeSuggestions to install the required binary.',
      vim.log.levels.WARN
    )
    code_suggestions.logging.error(msg)

    return nil
  end

  local command = subcommand
  table.insert(command, 1, lsp_binary_path)
  return command
end

function code_suggestions.register_personal_access_token()
  local token = vim.api.nvim_call_function('inputsecret', {
    'Enter a GitLab personal access token with the "api" scope: ',
  })
  vim.fn.system({
    '/bin/bash',
    '-c',
    'echo ' .. token .. ' | ' .. table.concat(
      code_suggestions.lsp_cmd({ 'token', 'register' }),
      ' '
    ),
  })

  if vim.v.shell_error == 0 then
    vim.notify('\n[gitlab.code_suggestions] Successfully registered your personal access token')
  else
    vim.notify(
      '\n[gitlab.code_suggestions] Unable to register your personal access token',
      vim.log.levels.ERROR
    )
  end
end

function code_suggestions.setup(logging, statusline, options)
  code_suggestions.logging = logging
  code_suggestions.options = options or {}
  code_suggestions.statusline = statusline

  vim.api.nvim_create_user_command('GitLabBootstrapCodeSuggestions', code_suggestions.bootstrap, {})

  if code_suggestions.options.enabled then
    vim.api.nvim_create_user_command('GitLabCodeSuggestionsStart', code_suggestions.start, {})
    vim.api.nvim_create_user_command('GitLabCodeSuggestionsStop', code_suggestions.stop, {})

    vim.api.nvim_create_autocmd({ 'FileType' }, {
      pattern = code_suggestions.options.auto_filetypes,
      callback = code_suggestions.start,
    })

    if code_suggestions.options.fix_newlines then
      vim.api.nvim_create_autocmd({ 'CompleteDonePre' }, {
        callback = function()
          vim.cmd([[s/\%x00/\r/ge]])
        end,
      })
    end
  end
end

function code_suggestions.start()
  if not code_suggestions.check_personal_access_token() then
    vim.notify(
      string.format(
        '[gitlab.code_suggestions]: not starting LSP client since personal access token check failed'
      ),
      vim.log.levels.WARN
    )
    return
  end

  vim.lsp.start({
    name = 'gitlab_code_suggestions',
    cmd = code_suggestions.lsp_cmd({
      'serve',
      '--name',
      'test',
      '--srcdir',
      vim.fn.getcwd(),
      '--timeout-seconds',
      '100',
    }),
    root_dir = vim.fn.getcwd(),
    before_init = function(params, _config)
      local os = utils.current_os()
      local arch = utils.current_arch()
      local nvim_version = tostring(vim.version._version(vim.version()))

      params.clientInfo = {
        name = 'Neovim',
        version = nvim_version
          .. '; gitlab.vim (v'
          .. globals.PLUGIN_VERSION
          .. '); arch:'
          .. arch
          .. '; os:'
          .. os
          .. ')',
      }
    end,
  })
end

function code_suggestions.stop()
  vim.lsp.stop_client(vim.lsp.get_active_clients({
    filter = 'gitlab_code_suggestions',
  }))
end

function code_suggestions.token_check_cmd()
  return code_suggestions.lsp_cmd({ 'token', 'check' })
end

return code_suggestions
