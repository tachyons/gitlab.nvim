local notifier = require('gitlab.notifier')

-- Lua module: gitlab.lsp.workspace
local M = {}

function M.new()
  local notify_lsp_client = function()
    return nil
  end

  return {
    configuration = {},
    change_configuration = function(self, cfg)
      local updated = vim.tbl_extend('keep', cfg, self.configuration)
      if not vim.deep_equal(self.configuration, updated) then
        self.configuration = updated
      end

      notify_lsp_client('workspace/didChangeConfiguration', {
        settings = self.configuration,
      })

      notifier.notify('gitlab.vim: Workspace configuration changed', vim.log.levels.WARN)
    end,
    subscribe_client = function(client_id)
      notifier.notify(
        'gitlab.vim: Subscribing client ' .. tostring(client_id),
        vim.lsp.log_levels.DEBUG
      )
      notify_lsp_client = function(...)
        local client = vim.lsp.get_client_by_id(client_id)
        return client and client.notify(...)
      end
    end,
  }
end

return M
