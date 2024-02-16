local notifier = require('gitlab.notifier')
local rest = require('gitlab.api.rest')

local enforce_gitlab = {}

local function instance_version()
  local gitlab_metadata, err = rest.metadata()
  if err then
    return nil, err
  end

  return vim.version.parse(gitlab_metadata.version)
end

function enforce_gitlab.at_least(min)
  local expected = vim.version.parse(min)
  local actual, err = instance_version()
  if err then
    notifier.notify(err, vim.log.levels.WARN)
    return nil
  end

  if actual < expected then
    return false
  end

  return true
end

return enforce_gitlab
