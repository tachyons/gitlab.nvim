local jobs = require('gitlab.lib.jobs')

local function _default_opts()
  local auth = require('gitlab.authentication').default_resolver():resolve()
  if auth then
    return {
      env = {
        GITLAB_TOKEN = auth.token(),
        GITLAB_URI = auth.url(),
      },
    }
  end
end

-- Lua module: gitlab.glab
--
-- Exposes GitLab CLI commands.
local M = { name = 'glab' }

function M.api(endpoint, req)
  req = vim.tbl_extend('keep', req or {}, { params = {} })
  local cmd = { 'glab', 'api', endpoint }
  for param, value in pairs(req.params) do
    table.insert(cmd, '-f')
    table.insert(cmd, string.format('%s=%s', param, value))
  end

  if req.method then
    table.insert(cmd, '-X')
    table.insert(cmd, req.method)
  end

  local job, err = jobs.start_wait(cmd, _default_opts())
  if err then
    return nil, err
  end

  local ok, decoded = pcall(function()
    return vim.fn.json_decode(job.stdout)
  end)
  if ok then
    if decoded and decoded.error_description then
      return decoded, decoded.error_description
    end

    return decoded
  end

  return nil, 'Unable to decode API response'
end

function M.available()
  return vim.fn.exepath('glab') ~= ''
end

function M.auth_status()
  if not M.available() then
    return ''
  end

  local job, err = jobs.start_wait({ 'glab', 'auth', 'status' }, _default_opts())
  if err then
    return nil, err
  end

  return job.stdout
end

function M.version()
  if not M.available() then
    return ''
  end

  local job, err = jobs.start_wait({ 'glab', 'version' }, {})
  if err then
    return nil, err
  end

  return job.stdout
end

function M.warning_enabled()
  return not vim.g.gitlab_api_provider_glab_disabled
end

return M
