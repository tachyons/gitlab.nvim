local globals = require('gitlab.globals')
local function neovim_version()
  local version = vim.version()
  if vim.fn.has('nvim-0.10') == 1 then
    return tostring(version)
  end

  local semver = string.format('%s.%s.%s', version.major, version.minor, version.patch)
  if version.prerelease and version.prerelease ~= vim.NIL then
    semver = semver .. '-' .. version.prerelease
  end
  if version.build and version.build ~= vim.NIL then
    semver = semver .. '+' .. version.build
  end
  return semver
end

return {
  default_config = {
    before_init = function(initialize_params, _config)
      initialize_params.clientInfo = {
        name = 'gitlab.vim',
        version = globals.PLUGIN_VERSION,
      }
    end,
    init_options = {
      extension = {
        name = 'gitlab.vim',
        version = globals.PLUGIN_VERSION,
      },
      ide = {
        name = 'Neovim',
        version = neovim_version(),
        vendor = 'Neovim',
      },
    },
  },
}
