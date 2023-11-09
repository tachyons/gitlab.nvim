local curl = require('gitlab.curl')
local glab = require('gitlab.glab')

-- Lua module: gitlab.api.rest
local M = {}

local function api_v4_path(path) --{{{
  local config = require('gitlab.config').current()
  path = path or ''
  path = path:gsub('^/', '')

  return vim.fn.join({
    config.gitlab_url,
    'api',
    'v4',
    path,
  }, '/')
end --}}}

function M.current_personal_access_token(request_options)
  local url = api_v4_path('/personal_access_tokens/self')

  if glab.available() then
    return glab.api(url, request_options)
  end

  if curl.available() then
    return curl.request(url, request_options)
  end

  return nil, 'Expected either "glab" or "curl" to be executable under PATH.'
end

return M
