local rest = require('gitlab.api.rest')
local config = require('gitlab.config')

local M = {}

local function url_encode_parent(str)
  -- For now we just need to handle / for projects and namespaces
  return str:gsub('/', '%%2F')
end

local function string_without_prefix(str, prefix)
  local s, e = str:find(prefix, 1, true)
  if s ~= 1 or e == nil then
    return nil
  end

  return str:sub(e + 1)
end

function M.resource_url_to_api_url(url)
  local cfg = config.current()
  -- Remove possible trailing slash
  local base_url = cfg.gitlab_url:gsub('/$', '')
  local resource_path = string_without_prefix(url, base_url)

  if not resource_path then
    return nil, url .. ' does not start with gitlab_url ' .. cfg.gitlab_url
  end

  local parent_path, resource_type, resource_id = resource_path:match('/(.+)%/%-%/([%w_]+)%/(%d+)')

  if not resource_id then
    return nil, 'Invalid GitLab resource URL: ' .. url
  end

  local api_parent

  if resource_type == 'merge_requests' or resource_type == 'issues' then
    api_parent = 'projects'
  elseif resource_type == 'epics' then
    api_parent = 'groups'
    -- Epics already have groups/ in the original URL while other resources don't
    parent_path = parent_path:gsub('groups/', '')
  else
    return nil, 'Invalid Resource Type: ' .. resource_type
  end

  local encoded_parent_path = url_encode_parent(parent_path)
  local path = api_parent
    .. '/'
    .. encoded_parent_path
    .. '/'
    .. resource_type
    .. '/'
    .. resource_id

  return rest.api_v4_url(path)
end

return M
