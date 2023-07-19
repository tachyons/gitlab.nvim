-- Add test dependencies to the runtimepath
vim.opt.rtp:append(vim.fn.expand('$HOME/.local/share/nvim/site/pack/vendor/start/plenary.nvim'))

-- Load plugins which are test dependencies
vim.cmd('runtime plugin/plenary.vim')

-- Add this plugin to the runtimepath
vim.opt.rtp:append('.')

-- Disable plugin loading outside of specs.
vim.g.gitlab_autoload = false
