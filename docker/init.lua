vim.opt.rtp:prepend('.')

if vim.env.PLUGIN_MANAGER == "lazy" then
  require('plugin_managers.lazy').setup()
elseif vim.env.PLUGIN_MANAGER == "packer" then
  require('plugin_managers.packer').setup()
else
  require('plugin_managers.packadd').setup()
end
