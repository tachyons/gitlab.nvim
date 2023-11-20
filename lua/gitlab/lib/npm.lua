return function(...)
  local jobs = require('gitlab.lib.jobs')
  local gitlab = require('gitlab')

  local cmd = vim.tbl_flatten({ 'npm', ... })
  local cwd = gitlab.plugin_root()

  return {
    cmd = cmd,
    cwd = cwd,
    exec = function()
      return jobs.start_wait(cmd, { cwd = cwd })
    end,
  }
end
