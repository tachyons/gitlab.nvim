-- Skip loading if this script has already excuted.
if vim.g.gitlab_plugin_loaded then
  return
end

vim.g.gitlab_plugin_loaded = true
if vim.g.gitlab_autoload ~= false then
  require('gitlab').setup({})
end
