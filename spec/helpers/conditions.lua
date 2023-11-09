local personal_access_token = require('gitlab.authentication.personal_access_token')
local validate = require('gitlab.config.validate')
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
  token = function(opts)
    opts = vim.tbl_extend('keep', opts or {}, {
      require_scopes = {},
      using = 'GITLAB_TOKEN',
    })

    vim.validate({
      opts = { opts, validate.is_dict },
      require_scopes = { opts.require_scopes, validate.is_string_list },
      using = { opts.using, 'string' },
    })

    local missing_scopes = {}
    local _met
    local ok, subject_token = pcall(function()
      return personal_access_token.from_env(opts.using)
    end)

    local _validation_err
    if not ok then
      _met = false
      _validation_err = subject_token
    end

    return {
      met = function()
        _met = _met and M.run_integration_tests.met()
        if _met ~= nil then
          return _met
        end

        for _, required_scope in ipairs(opts.require_scopes) do
          if not vim.tbl_contains(subject_token.scopes(), required_scope) then
            table.insert(missing_scopes, required_scope)
          end
        end

        _met = #missing_scopes == 0
        return _met
      end,
      unmet = function()
        if not M.run_integration_tests.met() then
          return M.run_integration_tests.unmet()
        end

        if _validation_err then
          pending_because(_validation_err)
        end

        if #missing_scopes > 0 then
          pending_because(vim.fn.join({
            string.format(
              'Skipping test due to token missing required scopes. Did you export %s properly?',
              opts.using
            ),
            string.format(
              '%s\texpected: (a personal access token including scopes %s)',
              PENDING_INDENT,
              vim.fn.json_encode(missing_scopes)
            ),
            string.format('%s\t     got: %s', PENDING_INDENT, subject_token.json()),
          }))
        end
      end,
    }
  end,
}

return M
