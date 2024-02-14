local M = {}

function M.create()
  local autocmd_groups = {
    code_suggestions = vim.api.nvim_create_augroup('GitLabCodeSuggestions', { clear = true }),
  }
  local auth = require('gitlab.authentication').default_resolver()
  local workspace = require('gitlab.lsp.workspace').new()

  require('gitlab.commands.api').create()
  require('gitlab.commands.code_suggestions').create({
    auth = auth,
    group = autocmd_groups.code_suggestions,
    workspace = workspace,
  })
  require('gitlab.commands.configure').create({
    auth = auth,
    workspace = workspace,
  })
end

return M
