-- Lua module: gitlab.authentication.health
local M = {}

local function check_auth_status(auth, err)
  local config = require('gitlab.config').current()
  local url = auth and auth.url() or config.gitlab_url
  local host = require('gitlab.lib.gitlab_host').parse_http_url(url)

  vim.health.start(string.format('%s (%s)', host.hostname, host.protocol))
  vim.health.info('GitLab URL: ' .. config.gitlab_url)

  if auth and auth:token_set() then
    vim.health.ok('Personal access token configured.')
  else
    vim.health.error(err, {
      'Use :GitLabConfigure to interactively update your GitLab connection settings.',
    })
  end
end

local function check_gitlab_metadata()
  local rest = require('gitlab.api.rest')
  local metadata, err = rest.metadata()
  if not err then
    vim.health.info(
      'GitLab version: ' .. metadata.version .. ' (revision: ' .. metadata.revision .. ')'
    )
    if metadata.enterprise then
      vim.health.info('Edition: Enterprise Edition (EE)')
    elseif metadata.enterprise == false then
      vim.health.info('Edition: Community Edition (CE)')
    end
  else
    vim.health.warn(err, {
      'Refer to the Metadata API docs at https://docs.gitlab.com/ee/api/metadata.html',
    })
  end
end

M.check = function()
  local auth, err = require('gitlab.authentication').default_resolver():resolve()
  check_auth_status(auth, err)
  check_gitlab_metadata()
end

return M
