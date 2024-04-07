local rest = require('gitlab.api.rest')

local enforce_gitlab = {}

local function instance_version()
  local gitlab_metadata, err = rest.metadata()
  if err then
    return nil, err
  end

  if not gitlab_metadata or not gitlab_metadata.version then
    return nil,
      string.format(
        'unexpected response checking GitLab version: %s',
        vim.fn.json_encode(gitlab_metadata)
      )
  end

  return vim.version.parse(gitlab_metadata.version)
end

function enforce_gitlab.at_least(min)
  local expected = vim.version.parse(min)
  local actual, err = instance_version()
  if err then
    return nil, err
  end

  if actual < expected then
    return false
  end

  return true
end

return enforce_gitlab
