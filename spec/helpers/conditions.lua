local env_vars = require('spec.helpers.env_vars')
local colorize = require('spec.helpers.colorize')
local snowplow_micro = require('spec.helpers.snowplow_micro')

local PENDING_INDENT = '\n\t||\t'
local function pending_because(reason)
  reason = colorize.gray('[skipped] ' .. reason)
  -- luacheck: globals pending
  pending(PENDING_INDENT .. reason)
end

local M
M = {
  run_integration_tests = {
    met = function()
      return env_vars.bool('RUN_INTEGRATION_TESTS', false)
    end,
    unmet = function()
      pending_because('RUN_INTEGRATION_TESTS was not set')
    end,
  },
  snowplow_micro_available = {
    met = function()
      if M.run_integration_tests.met() then
        return snowplow_micro.available()
      end

      return false
    end,
    unmet = function()
      if not M.run_integration_tests.met() then
        return M.run_integration_tests.unmet()
      end

      if env_vars.bool('CI', false) then
        error(colorize.red('[failed] Snowplow Micro unavailable.'))
      else
        pending_because('Snowplow Micro unavailable.')
      end
    end,
  },
  token = function()
    return {
      met = function()
        if M.run_integration_tests.met() then
          return
        end
        -- TODO: Current token check
        return false
      end,
      unmet = function()
        if not M.run_integration_tests.met() then
          return M.run_integration_tests.unmet()
        end

        pending_because('Personal Access Token with sufficient scopes not available.')
      end,
    }
  end,
}

return M
