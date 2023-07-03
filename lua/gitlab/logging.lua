local logging = {}

function logging.info(msg)
  logging._log(msg, "INFO")
end

function logging.warn(msg)
  logging._log(msg, "WARN")
end

function logging.error(msg)
  logging._log(msg, "ERROR")
end

function logging.debug(msg, f)
  local force = f or false

  if force or GITLAB_VIM.debug then
    logging._log(msg, "DEBUG")
  end
end

function logging.format_line(msg, level, t)
  local timestamp = t or "%Y-%m-%d %H:%M:%S"

  local line = string.format("%s: %s (%s): %s", os.date(timestamp), level, GITLAB_VIM.version, msg)

  return line
end

function logging._log(msg, level)
  local log_file_path = '/tmp/gitlab.vim.log'
  local log_file = io.open(log_file_path, "a")

  io.output(log_file)
  io.write(logging.format_line(msg, level) .. "\n")
  io.close(log_file)
end

function logging.setup()
end

return logging
