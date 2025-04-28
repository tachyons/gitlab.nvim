-- Lua module: gitlab.lib.stdio_handler
local M = {}

function M.extend_jobstart_options(opts, handle_exit)
  vim.validate({
    handle_exit = { handle_exit, 'function' },
  })

  local stderr = {}
  local stdout = {}

  return vim.tbl_extend('force', opts or {}, {
    on_exit = function(_job_id, exit_code, _event)
      handle_exit({
        exit_code = exit_code,
        stdout = vim.trim(vim.fn.join(stdout, '\n')),
        stderr = vim.trim(vim.fn.join(stderr, '\n')),
      })
    end,
    on_stdout = function(_job_id, data, _event)
      stdout = data
    end,
    on_stderr = function(_job_id, data, _event)
      stderr = data
    end,
    stdout_buffered = true,
    stderr_buffered = true,
  })
end

return M
