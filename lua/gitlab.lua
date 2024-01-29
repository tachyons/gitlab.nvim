local gitlab = {}

function gitlab.plugin_root()
  return vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ':p:h:h')
end

function gitlab.setup(user_config)
  require('gitlab.config').setup(user_config)
  require('gitlab.resource_editing')
end

return gitlab
