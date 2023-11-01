local jobs = require('gitlab.lib.jobs')

-- Lua module: gitlab.glab
--
-- Exposes GitLab CLI commands.
local M = {}

function M.api(endpoint, req)
  local auth = require('gitlab.authentication').default_resolver():resolve()
  local opts = {
    env = {
      GITLAB_TOKEN = auth.token(),
      GITLAB_URI = auth.url(),
    },
  }

  local cmd = { 'glab', 'api', endpoint }
  for param, value in pairs(req.params) do
    table.insert(cmd, '-f')
    table.insert(cmd, string.format('%s=%s', param, value))
  end

  local job, err = jobs.start_wait(cmd, opts)
  if err then
    return nil, err
  end

  local ok, decoded = pcall(function()
    return vim.fn.json_decode(job.stdout)
  end)
  if ok then
    return decoded
  end

  return nil, 'Unable to decode API response'
end

function M.available()
  return vim.fn.exepath('glab') ~= ''
end

return M
