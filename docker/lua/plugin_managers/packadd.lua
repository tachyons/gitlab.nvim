local notifier = require('gitlab.notifier')

local M = {}

local function packadd(plugin_path, pattern)
  local _, pattern_end = string.find(plugin_path, pattern)

  if pattern_end ~= nil then
    vim.cmd('packadd '..string.sub(plugin_path, pattern_end+1))
  end
end

local function git_clone_plugin(params)
  local install_path = vim.fn.stdpath('data')..'/'..params.destination

  if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    local git_cmd = { 'git', 'clone', '--depth', '1' }
    if params.branch then
      table.insert(git_cmd, '--branch='..params.branch)
    end
    table.insert(git_cmd, params.source)
    table.insert(git_cmd, install_path)

    local output = vim.fn.system(git_cmd)

    if vim.v.shell_error == 0 then
      notifier.notify(output, vim.log.levels.DEBUG)
      packadd(params.destination, '^site/pack/[%w_]+/start')
    else
      notifier.notify(output, vim.log.levels.ERROR)
      return
    end
  end

  packadd(params.destination, '^site/pack/[%w_]+/opt')
end

function M.setup()
  if vim.env.LSP_INSTALLER == 'mason' then
    git_clone_plugin({
      destination = 'site/pack/plugins/start/mason.nvim',
      source = 'https://github.com/williamboman/mason.nvim.git',
    })
    require('mason').setup()
  end

  git_clone_plugin({
    branch = vim.env.GITLAB_VIM_BRANCH or 'main',
    destination = 'site/pack/gitlab/start/gitlab.vim',
    source = 'https://gitlab.com/gitlab-org/editor-extensions/gitlab.vim.git',
  })

  require('gitlab').setup({})

  if vim.env.LSP_INSTALLER == 'gitlab.vim' then
    vim.cmd.GitLabCodeSuggestionsInstallLanguageServer()
  end
end

return M
