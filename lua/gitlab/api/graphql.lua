local curl = require('gitlab.curl')
local glab = require('gitlab.glab')

-- Lua module: gitlab.api.graphql
local M = {}

local function graphql_url() --{{{
  local config = require('gitlab.config').current()

  return vim.fn.join({
    config.gitlab_url,
    'api',
    'graphql',
  }, '/')
end --}}}

function M.execute(query, variables)
  if glab.available() then
    return glab.api(graphql_url(), {
      method = 'POST',
      params = {
        query = query,
        variables = variables and vim.fn.json_encode(variables),
      },
    })
  end

  if curl.available() then
    return curl.request(graphql_url(), {
      body = {
        query = query,
        variables = variables and vim.fn.json_encode(variables),
      },
    })
  end

  return nil, 'Expected either "glab" or "curl" to be executable under PATH.'
end

function M.current_user_duo_status()
  return M.execute([[
    query currentUserDuoStatus {
      currentUser {
        duoCodeSuggestionsAvailable
      }
    }
  ]])
end

function M.project_settings(project)
  return M.execute(
    [[
    query GetProject($project: ID!) {
      project(fullPath: $project) {
        duoFeaturesEnabled
      }
    }
  ]],
    { project = project }
  )
end

function M.update_project_settings_duo_features_enabled(project, enabled)
  vim.validate({
    project = { project, 'string' },
    enabled = { enabled, 'boolean' },
  })

  local variables = {
    fullPath = project,
    enabled = enabled,
  }
  return M.execute(
    [[
    mutation UpdateProjectSettings_duoFeaturesEnabled($fullPath: ID!, $enabled: Boolean!) {
      projectSettingsUpdate(input: { fullPath: $fullPath, duoFeaturesEnabled: $enabled }) {
        errors
      }
    }
  ]],
    variables
  )
end

return M
