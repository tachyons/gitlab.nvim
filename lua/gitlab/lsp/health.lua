-- Lua module: gitlab.lsp.health
local M = {
  features = {
    {
      id = 'authentication',
      name = 'Authentication',
      engagedChecks = {},
    },
    {
      id = 'chat',
      name = 'Chat',
      engagedChecks = {},
    },
    {
      id = 'code_suggestions',
      name = 'Code Suggestions',
      engagedChecks = {},
    },
  },
}

M.check = function()
  for _, feature in ipairs(M.features) do
    vim.health.start(feature.name)
    if #feature.engagedChecks == 0 then
      vim.health.ok('no issues found')
    else
      for _, check in ipairs(feature.engagedChecks) do
        vim.health.warn(
          check.details
            or 'Language server engaged feature state check: ' .. vim.fn.json_encode(check)
        )
      end
    end
  end
end

M.refresh_feature = function(id, state)
  for _, feature in ipairs(M.features) do
    if feature.id == id then
      feature.engagedChecks = state and state.engagedChecks or {}
    end
  end
end

return M
