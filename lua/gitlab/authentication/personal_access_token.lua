local memoize = require('gitlab.lib.memoize')
local rest = require('gitlab.api.rest')

-- Lua module: gitlab.authentication.personal_access_token
local M = {}

function M.new(token)
  local token_response = memoize(function()
    return rest.current_personal_access_token({
      auth = {
        token = token,
      },
    })
  end)
  return {
    scopes = function()
      return token_response().scopes
    end,
    json = function()
      return vim.fn.json_encode(token_response())
    end,
  }
end

function M.from_env(name)
  local token = vim.env[name]
  if token then
    return M.new(token)
  end

  error(string.format('Missing personal access token in environment variable "%s"', name))
end

return M
