local notifier = require('gitlab.notifier')
local globals = require('gitlab.globals')
local statusline = require('gitlab.statusline')
local lsp = require('gitlab.lsp.health')

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
  ['$/gitlab/featureStateChange'] = function(_err, result)
    local checks_passed = true
    local feature_states = result and result[1]
    for _, feature_state in ipairs(feature_states) do
      lsp.refresh_feature(feature_state.featureId, feature_state)
      if feature_state.engagedChecks and #feature_state.engagedChecks > 0 then
        checks_passed = false
      end
    end

    if checks_passed then
      statusline.update_status_line(globals.GCS_AVAILABLE)
    else
      statusline.update_status_line(globals.GCS_UNAVAILABLE)
    end
  end,
}
