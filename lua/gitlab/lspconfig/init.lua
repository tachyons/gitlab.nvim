local gitlab_lsp = require('gitlab.lspconfig.server_configurations.gitlab_lsp')

local M = {}

function M.setup(user_config)
  local cfg = vim.tbl_deep_extend('keep', user_config, gitlab_lsp.default_config)
  return vim.lsp.start(cfg)
end

return M
