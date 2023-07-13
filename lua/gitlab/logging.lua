local logging = {
  options = {
    debug = false,
    enabled = true,
    version = 'unknown',
  },
}

local merge = require('gitlab.utils').merge

function logging.info(msg)
  logging._log(msg, 'INFO')
end

function logging.warn(msg)
  logging._log(msg, 'WARN')
end

function logging.error(msg)
  logging._log(msg, 'ERROR')
end

function logging.debug(msg, f)
  local force = f or false

  if force or logging.debug_enabled() then
    logging._log(msg, 'DEBUG')
  end
end

function logging.debug_enabled()
  return logging.options.debug
end

function logging.format_line(msg, level, t)
  local timestamp = t or '!%Y-%m-%d %H:%M:%S'
  local line =
    string.format('%s: %s (%s): %s', os.date(timestamp), level, logging.options.version, msg)

  return line
end

function logging._log(msg, level)
  if logging.options.enabled == true then
    local log_file_path = '/tmp/gitlab.vim.log'
    local log_file = io.open(log_file_path, 'a')

    local fh = io.output(log_file)
    fh:write(logging.format_line(msg, level) .. '\n')
    fh:close(log_file)
  end
end

function logging.setup(options)
  logging.options = merge(logging.options, options)
end

return logging
