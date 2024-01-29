local rest = require('gitlab.api.rest')

local M = {}

local function url_encode_parent(str)
  -- For now we just need to handle / for projects and namespaces
  return str:gsub('/', '%%2F')
end

function M.resource_url_to_api_url(url)
  local parent_path, resource_type, resource_id = url:match('gitlab%.com/(.+)%/%-%/([%w_]+)%/(%d+)')

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
