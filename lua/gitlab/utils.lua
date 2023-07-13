local utils = {}

local utils_vim = require('lua.gitlab.utils_vim')

function utils.merge(orig, overrides)
  local merged = {}
  if orig ~= nil then
    for k, v in pairs(orig) do
      merged[k] = v
    end
  end

  if overrides ~= nil then
    for k, v in pairs(overrides) do
      merged[k] = v
    end
  end

  return merged
end

function utils.user_data_path()
  return utils_vim.fn.stdpath('data')
end

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

  return string.format('GCS: %s', m)
end

function utils.current_os()
  local res = utils_vim.fn.system({ 'uname', '-s' })
  res = string.gsub(res, '%s+', '')

  return string.lower(res)
end

function utils.current_arch()
  local res = utils_vim.fn.system({ 'uname', '-m' })
  res = string.gsub(res, '%s+', '')

  if res == 'arm64' then
    res = 'amd64'
  end

  return string.lower(res)
end

function utils.path_exists(path)
  return utils_vim.loop.fs_stat(path)
end

function utils.exec_cmd(cmd, fn)
  local stdout = ''
  local stderr = ''

  return utils_vim.fn.jobstart(cmd, {
    on_stdout = function(_job_id, data, _event)
      stdout = stdout .. vim.fn.join(data)
    end,

    on_stderr = function(_job_id, data, _event)
      stderr = stderr .. vim.fn.join(data)
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

      fn(result)
    end,
  })
end

function utils.dump(o)
  if type(o) == 'table' then
    local s = '{ '
    for k, v in pairs(o) do
      if type(k) ~= 'number' then
        k = '"' .. k .. '"'
      end
      s = s .. '[' .. k .. '] = ' .. utils.dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

return utils
