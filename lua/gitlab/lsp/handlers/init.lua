local notifier = require('gitlab.notifier')
local globals = require('gitlab.globals')
local statusline = require('gitlab.statusline')

-- Lua module: gitlab.lsp.handlers
return {
  ['$/gitlab/token/check'] = function(_err, result, _ctx, _config)
    local message
    if result and result.message then
      message = 'gitlab.vim: ' .. result.message
    else
      message = 'gitlab.vim: Unexpected error from LSP server: ' .. vim.inspect(result)
    end

    notifier.notify(message, vim.log.levels.ERROR, {
      title = 'LSP method: $/gitlab/token/check',
    })
    statusline.update_status_line(globals.GCS_UNAVAILABLE)
  end,
}
