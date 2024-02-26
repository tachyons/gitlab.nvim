local M = {}

local function can_notify(level)
  level = level or 0
  local config = require('gitlab.config').current().minimal_message_level or 0

  return level >= config
end

---Notifies if messages above the minimal required by users on config.minimal_message_level
---@param msg string message to notify
---@param level number|nil same as |vim.lsp.log_levels|
---@param opts table|nil same options from |vim.notify|
function M.notify(msg, level, opts)
  if can_notify(level) then
    vim.notify(msg, level, opts)
  end
end

---Notifies only once if messages above the minimal required by users on config.minimal_message_level
---@param msg string message to notify
---@param level number|nil same as |vim.lsp.log_levels|
---@param opts table|nil same options from |vim.notify|
function M.notify_once(msg, level, opts)
  if can_notify(level) then
    vim.notify_once(msg, level, opts)
  end
end

return M
