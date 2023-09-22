-- Add test dependencies to the runtimepath
vim.opt.rtp:append(
  vim.fn.expand(
    vim.env.PLENARY_PATH or '$HOME/.local/share/nvim/site/pack/vendor/start/plenary.nvim'
  )
)

-- Load plugins which are test dependencies
vim.cmd('runtime plugin/plenary.vim')

-- Add this plugin to the runtimepath
vim.opt.rtp:append('.')
