-- Lua module: gitlab.authentication.provider
local env = require('gitlab.authentication.provider.env')
local prompt = require('gitlab.authentication.provider.prompt')

local M = {}

function M.env(keys, defaults)
  return env.new({
    keys = keys,
    defaults = defaults,
  })
end

function M.prompt(gitlab_url)
  return prompt.new({
    gitlab_url = gitlab_url,
  })
end

return M
