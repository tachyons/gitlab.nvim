local authentication = {}

local utils = require('lua.gitlab.utils')

function authentication.setup(logging)
  -- TODO: Support typescript language server.
  -- authentication.language_server = require('gitlab.language_server.go')

  authentication.logging = logging
end

function authentication.register()
  authentication.check_token()
end

function authentication.lsp_binary_path()
  local os = utils.current_os()
  local arch = utils.current_arch()

  if os == "" or arch == "" then
    return ""
  end

  local basename = "gitlab-code-suggestions-language-server-experiment"
  local filename = basename .. "-" .. os .. "-" .. arch

  return string.format("%s/%s", utils.user_data_path(), filename)
end

function authentication.token_check_cmd()
  local lsp_binary_path = authentication.lsp_binary_path()

  if lsp_binary_path == "" then
    local msg = string.format("'%s' does not exist?", lsp_binary_path)
    utils.print("ERROR: " .. msg)
    authentication.logging.error(msg)

    return nil
  end

  if not utils.path_exists(lsp_binary_path) then
    return nil
  end

  return { lsp_binary_path, "token", "check" }
end

function authentication.check_token()
  utils.print("Checking GitLab PAT..")

  local token_check_cmd = authentication.token_check_cmd()

  authentication.logging.debug(string.format("Using '%s'", token_check_cmd[1]))

  local fn = function(result)
    if result.exit_code == 0 then
      utils.print(result.stdout)
      authentication.logging.info(result.stdout)

      return true
    else
      local msg = string.format("Error detected, stdout=[%s], stderr=[%s], code=[%s]",
        result.stdout, result.stderr, result.exit_code)

      utils.print(msg)
      authentication.logging.error(msg)
    end

    return false
  end

  utils.exec_cmd(token_check_cmd, fn)
end

return authentication
