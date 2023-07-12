if vim.g.gitlab_autoload == false or vim.g.gitlab_plugin_loaded then
  return
end
vim.g.gitlab_plugin_loaded = true

require('gitlab').setup()
