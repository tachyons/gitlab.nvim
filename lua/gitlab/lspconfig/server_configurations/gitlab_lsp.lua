local globals = require('gitlab.globals')

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
        version = tostring(vim.version._version(vim.version())),
        vendor = 'Neovim',
      },
    },
  },
}
