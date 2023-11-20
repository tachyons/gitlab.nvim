-- Lua module: gitlab.health
local M = {}

M.check = function()
  vim.health.start('API providers')

  local api_providers = {
    require('gitlab.curl'),
    require('gitlab.glab'),
  }
  for _, provider in ipairs(api_providers) do
    vim.health.start(provider.name .. ' (optional)')
    if provider.available() then
      vim.health.ok(provider.name .. ' installed\n\t ' .. provider.version())
    elseif provider.enabled() then
      vim.health.warn(provider.name .. ' not found', provider.install_advice())
    else
      vim.health.ok(provider.name .. ' disabled')
    end
  end
end

return M
