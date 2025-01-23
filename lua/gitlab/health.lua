-- Lua module: gitlab.health
local M = {}

local log_levels = {
  [vim.lsp.log_levels.DEBUG] = 'DEBUG',
  [vim.lsp.log_levels.ERROR] = 'ERROR',
  [vim.lsp.log_levels.INFO] = 'INFO',
  [vim.lsp.log_levels.OFF] = 'OFF',
  [vim.lsp.log_levels.TRACE] = 'TRACE',
  [vim.lsp.log_levels.WARN] = 'WARN',
}

local function check_lsp_client_settings()
  vim.health.start('LSP client logs')

  local current_log_level = vim.lsp.log.get_level()
  local current_log_path = vim.lsp.get_log_path()
  vim.health.info('vim.lsp.log.get_log_path(): ' .. current_log_path)
  if current_log_level <= vim.lsp.log_levels.DEBUG then
    vim.health.warn('vim.lsp.log.get_level(): ' .. log_levels[current_log_level], {
      'DEBUG level LSP client logs contain sensitive workspace configuration.',
      'INFO level LSP client logs contain sensitive workspace configuration upon client exit.',
      'Use vim.lsp.set_log_level() to set log level to WARN, ERROR, or OFF.',
    })
  elseif current_log_level <= vim.lsp.log_levels.INFO then
    vim.health.warn('vim.lsp.log.get_level(): ' .. log_levels[current_log_level], {
      'INFO level LSP client logs contain sensitive workspace configuration upon client exit.',
      'Use vim.lsp.set_log_level() to set log level to WARN, ERROR, or OFF.',
    })
  else
    vim.health.ok('vim.lsp.log.get_level(): ' .. log_levels[current_log_level])
  end
end

local function check_api_providers()
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

M.check = function()
  check_lsp_client_settings()
  check_api_providers()
end

return M
