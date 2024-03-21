local jobs = require('gitlab.lib.jobs')

-- Lua module: gitlab.lib.git_remote
local M = {}

function M.remotes()
  if vim.fn.exepath('git') == '' then
    return nil, 'Unable to find "git" in PATH.'
  end

  local job, err = jobs.start_wait({ 'git', 'remote', '-v' })

  if err then
    return nil, err
  end

  local remotes = {}
  for _, line in ipairs(vim.fn.split(job.stdout, '\n')) do
    local remote = vim.fn.split(line)
    remotes[remote[1]] = remote[2]
  end

  return remotes
end

return M
