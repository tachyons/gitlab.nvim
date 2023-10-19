local M = {}

---Notifies only messages above the minimal required by users on config.minimal_message_level
---@param msg string message to notify
---@param level number|nil same as |vim.lsp.log_levels|
---@param opts table|nil same options from |vim.notify|
function M.notify(msg, level, opts)
  local config = require('gitlab.config').current().minimal_message_level or 0

  if (level or 0) >= config then
    vim.notify(msg, level, opts)
  end
end

return M
