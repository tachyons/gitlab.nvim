local curl = require('gitlab.curl')
local glab = require('gitlab.glab')
local config = require('gitlab.config')

-- Lua module: gitlab.api.rest
local M = {}

function M.api_v4_url(path) --{{{
  local cfg = config.current()
  path = path or ''
  path = path:gsub('^/', '')
  local base_url = cfg.gitlab_url:gsub('/$', '')

  return vim.fn.join({
    base_url,
    'api',
    'v4',
    path,
  }, '/')
end --}}}

function M.request(url, request_options)
  if glab.available() then
    return glab.api(url, request_options)
  end

  if curl.available() then
    return curl.request(url, request_options)
  end

  return nil, 'Expected either "glab" or "curl" to be executable under PATH.'
end

function M.current_personal_access_token(request_options)
  local url = M.api_v4_url('/personal_access_tokens/self')
  return M.request(url, request_options)
end

function M.metadata()
  local url = M.api_v4_url('/metadata')
  local response, err = M.request(url)

  return response, err
end

return M
