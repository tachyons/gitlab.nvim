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
    return true
  else
    vim.health.error(err, {
      'Use :GitLabConfigure to interactively update your GitLab connection settings.',
    })
    return false
  end
end

local function check_duo_status()
  local enforce_gitlab = require('gitlab.lib.enforce_gitlab')
  if not enforce_gitlab.at_least('16.8') then
    vim.health.warn('GitLab Duo Code Suggestions requires GitLab version 16.8 or later', {
      'Confirm your GitLab version: https://docs.gitlab.com/ee/user/version.html',
    })
    return
  end

  local graphql = require('gitlab.api.graphql')
  local pick = require('gitlab.lib.pick')

  local response, err = graphql.current_user_duo_status()
  err = err or pick(response, { 'errors', 1, 'message' })
  if err then
    vim.health.error('Unable to detect GitLab Duo status for current user: ' .. err)
    return
  end

  local current_user = pick(response, { 'data', 'currentUser' })
  if pick(current_user, { 'duoCodeSuggestionsAvailable' }) then
    vim.health.ok('GitLab Duo Code Suggestions: Available')
    return true
  else
    vim.health.warn('Code Suggestions is now a paid feature, part of Duo Pro.', {
      'Contact your GitLab administrator to upgrade.',
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
    vim.health.error(err, {
      'This healthcheck uses the Metadata API: https://docs.gitlab.com/ee/api/metadata.html',
      'Configure a Personal Access Token with the `read_api` scope to enable automatic version detection.',
    })
    return
  end
end

local function check_project_duo_status()
  local enforce_gitlab = require('gitlab.lib.enforce_gitlab')
  if not enforce_gitlab.at_least('16.8') then
    vim.health.warn('GitLab Duo Code Suggestions requires GitLab version 16.8 or later', {
      'Confirm your GitLab version: https://docs.gitlab.com/ee/user/version.html',
    })
    return
  end

  local graphql = require('gitlab.api.graphql')
  local pick = require('gitlab.lib.pick')

  local remotes = require('gitlab.lib.git_remote').remotes()
  local at_least_one_duo_project = false
  for name, uri in pairs(remotes) do
    local parsed = require('gitlab.lib.gitlab_project_url').parse(uri)
    local response, err = graphql.project_settings(parsed.full_path)
    err = err or pick(response, { 'errors', 1, 'message' })
    if err then
      vim.health.error(
        string.format('GitLab Duo status for this project is unknown %s (remote %s)', uri, name),
        { err }
      )
    else
      local project = pick(response, { 'data', 'project' })
      if pick(project, { 'duoFeaturesEnabled' }) then
        at_least_one_duo_project = true
        vim.health.ok(
          string.format('GitLab Duo is enabled for this project %s (remote %s)', uri, name)
        )
      else
        vim.health.warn(
          string.format('GitLab Duo is disabled for this project %s (remote %s)', uri, name)
        )
      end
    end
  end

  if not at_least_one_duo_project then
    vim.health.warn(
      'GitLab Duo Code Suggestions is disabled for this project. Please contact your administrator.',
      {
        'No remotes ('
          .. vim.fn.join(vim.fn.keys(remotes), ', ')
          .. ') appear to be GitLab projects with Duo enabled.',
      }
    )
    return
  end
end

M.check = function()
  local auth, err = require('gitlab.authentication').default_resolver():resolve()
  local auth_ok = check_auth_status(auth, err)
  if not auth_ok then
    vim.health.warn('Skipping authenticated health checks.')
    return
  end

  check_gitlab_metadata()
  if check_duo_status() then
    check_project_duo_status()
  end
end

return M
