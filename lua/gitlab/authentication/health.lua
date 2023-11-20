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

M.check = function()
  local auth, err = require('gitlab.authentication').default_resolver():resolve()
  check_auth_status(auth, err)
end

return M
