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

function M.query(query)
  if glab.available() then
    return glab.api(graphql_url(), {
      params = {
        query = query,
      },
    })
  end

  if curl.available() then
    return curl.request(graphql_url(), {
      body = {
        query = query,
      },
    })
  end

  return nil, 'Expected either "glab" or "curl" to be executable under PATH.'
end

function M.current_user_duo_status()
  return M.query([[
    query currentUserDuoStatus {
      currentUser {
        duoCodeSuggestionsAvailable
      }
    }
  ]])
end

return M
