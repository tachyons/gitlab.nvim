local stdio_handler = require('gitlab.lib.stdio_handler')

-- Lua module: gitlab.lib.jobs
local M = {}

-- Starts a command synchronously until the timeout defined in `opts.wait_millis` is exceeded.
--
---@param condition table|nil:  (default: See `run_integration_tests`)
---@param opts table: See :help :jobstart-options for implicit fields.
---@field wait_millis number|nil: the number of milliseconds to wait for the command to complete (default: 10,000).
---@return[0] table|nil a table including the exit code, stderr, and stdout. nil if the job failed to start.
---@return[1] string|nil a human readable error if job status indicated failure otherwise nil. See :help jobwait().
function M.start_wait(cmd, opts)
  local result
  opts = stdio_handler.extend_jobstart_options(opts, function(job)
    result = job
  end)

  local job_id = vim.fn.jobstart(cmd, opts)
  local wait_millis = opts.wait_millis or 10000

  local jobs = { job_id }
  local statuses = vim.fn.jobwait(jobs, wait_millis)

  local status = statuses[1]
  if status == -1 then
    return nil, 'timeout exceeded'
  elseif status == -2 then
    return nil, 'user interrupt'
  elseif status < 0 then
    return nil, 'job failed to start with status ' .. vim.inspect(status)
  end

  return result
end

return M
