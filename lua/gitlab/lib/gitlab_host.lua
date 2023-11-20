-- Lua module: gitlab.lib.gitlab_host
local M = {}

local http_url_pattern = '^(https?)://([^/]+)'

function M.parse_http_url(str)
  if not str then
    return {}
  end

  local protocol, hostname = str:match(http_url_pattern)
  return {
    hostname = hostname,
    protocol = protocol,
  }
end

return M
