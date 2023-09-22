local M = {}

function M.setup()
  local lazypath = vim.fn.stdpath('data') .. '/site/pack/plugin_managers/opt/lazy.nvim'
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      'git',
      'clone',
      '--filter=blob:none',
      'https://github.com/folke/lazy.nvim.git',
      '--branch=stable', -- latest stable release
      lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)

  local plugins = {
  }

  if vim.env.LSP_INSTALLER == 'mason' then
    table.insert(plugins, {
     'williamboman/mason.nvim'
   })
  end

  table.insert(plugins, {
    'https://gitlab.com/gitlab-org/editor-extensions/gitlab.vim.git',
    branch = vim.env.GITLAB_VIM_BRANCH or 'main',
    config = function()
      require('gitlab').setup({})

      if vim.env.LSP_INSTALLER == 'gitlab.vim' then
        vim.cmd.GitLabCodeSuggestionsInstallLanguageServer()
      end
    end,
  })

  require('lazy').setup(plugins)
end

return M
