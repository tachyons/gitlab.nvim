-- Skip loading if this script has already excuted.
if vim.g.gitlab_plugin_loaded then
  return
end

vim.g.gitlab_plugin_loaded = true

require('gitlab.commands').create()
