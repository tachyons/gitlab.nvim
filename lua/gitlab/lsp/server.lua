local M = {}

local function resolve_exepath()
  local path = vim.env.GITLAB_VIM_LSP_BINARY_PATH

  if not path then
    local config = require('gitlab.config').current()
    path = config.code_suggestions.lsp_binary_path
  end

  if not path then
    path = 'node'
  end

  return vim.fn.exepath(path)
end

function M.new()
  local exepath = resolve_exepath()
  local node_main_script = vim.fn.join({
    require('gitlab').plugin_root(),
    'node_modules/@gitlab-org/gitlab-lsp/out/node/main.js',
  }, '/')

  return {
    cmd = function(self, opts)
      opts = opts or {}
      local args = vim.deepcopy(opts.args) or {}
      if self.is_node() then
        table.insert(args, 1, node_main_script)
      end

      return vim.tbl_flatten({ exepath, args })
    end,
    is_executable = function()
      return exepath ~= ''
    end,
    is_installed = function(self)
      if not self.is_executable() then
        return false
      end

      if self.is_node() then
        return vim.loop.fs_stat(node_main_script)
      end

      return true
    end,
    is_node = function()
      return exepath:match('/node$')
    end,
  }
end

return M
