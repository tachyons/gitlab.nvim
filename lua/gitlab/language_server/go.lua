local server = {}

function server.register_personal_access_token(token)
  vim.fn.system({
    '/bin/bash',
    '-c',
    -- TODO: Verify the server is available in PATH.
    'echo '
      .. token
      .. ' | gitlab-code-suggestions-language-server-experiment token register',
  })

  if vim.v.shell_error == 0 then
    vim.notify('[gitlab.language_server] Successfully registered your personal access token')
  else
    vim.notify(
      '[gitlab.language_server] Unable to register your personal access token',
      vim.log.levels.ERROR
    )
  end
end

return server
