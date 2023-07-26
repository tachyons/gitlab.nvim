local utils = {}
local fn = vim.fn
local loop = vim.loop

function utils.print(m)
  if m == '' then
    return
  end

  print(utils.formatted_line_for_print(m))
end

function utils.formatted_line_for_print(m)
  if m == '' then
    return
  end

  return string.format('[gitlab.vim] %s', m)
end

function utils.current_os()
  return string.lower(loop.os_uname().sysname)
end

function utils.current_arch()
  local res = loop.os_uname().machine

  if res == 'arm64' then
    res = 'amd64'
  end

  return string.lower(res)
end

function utils.exec_cmd(cmd, callback)
  local stdout = ''
  local stderr = ''

  return fn.jobstart(cmd, {
    on_stdout = function(_job_id, data, _event)
      stdout = stdout .. '\n' .. vim.fn.join(data)
      stdout = vim.trim(stdout)
    end,

    on_stderr = function(_job_id, data, _event)
      stderr = stderr .. '\n' .. vim.fn.join(data)
      stderr = vim.trim(stderr)
    end,

    on_exit = function(_job_id, exit_code, _event)
      local result = { exit_code = exit_code, stdout = stdout, stderr = stderr, msg = '' }

      if exit_code ~= 0 then
        result.msg = string.format(
          'Error detected, stdout=[%s], stderr=[%s], code=[%s]',
          stdout,
          stderr,
          exit_code
        )
      end

      callback(result)
    end,
  })
end

return utils
