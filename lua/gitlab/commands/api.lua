local rest = require('gitlab.api.rest')
local notifier = require('gitlab.notifier')

local function gitlab_metadata()
  local response, err = rest.metadata()

  if err then
    notifier.notify(err, vim.log.levels.ERROR)
  else
    notifier.notify(
      response.version .. ' (revision: ' .. response.revision .. ')',
      vim.log.levels.INFO,
      { title = 'GitLab version' }
    )
  end
end

return {
  create = function()
    vim.api.nvim_create_user_command('GitLabVersion', gitlab_metadata, {
      desc = 'Starts the Code Suggestions LSP client integration.',
    })
  end,
}
