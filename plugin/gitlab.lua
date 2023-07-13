-- Skip loading if this script has already excuted.
if vim.g.gitlab_plugin_loaded then
  return
end

vim.g.gitlab_plugin_loaded = true

local gitlab = require('gitlab').init({})

if vim.g.gitlab_autoload ~= false then
  gitlab.setup({})
end
