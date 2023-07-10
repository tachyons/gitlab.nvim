local authentication = {}

function authentication.register(_command)
   vim.ui.input({
     prompt = 'Enter your GitLab Personal Access Token: '
   }, function(token) authentication.language_server.register_personal_access_token(token) end)
end

function authentication.setup(_options)
  -- TODO: Support typescript language server.
  authentication.language_server = require('gitlab.language_server.go')

  vim.api.nvim_create_user_command("GitLabRegisterToken", authentication.register, { nargs = 0 })
end

return authentication
