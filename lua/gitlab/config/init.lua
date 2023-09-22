local M = {}

local defaults = require('gitlab.config.defaults')
local env = require('gitlab.config.env')
local validate = require('gitlab.config.validate')

local _current
function M.setup(user_config)
  local merged = vim.deepcopy(defaults)
  if type(env) == 'table' then
    merged = vim.tbl_deep_extend('force', merged, env)
  end

  if type(user_config) == 'table' then
    merged = vim.tbl_deep_extend('force', merged, user_config)
  end

  validate(merged)
  _current = merged
end

function M.current()
  if not _current then
    M.setup({})
  end

  return _current
end
return M
