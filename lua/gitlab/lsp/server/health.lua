local npm = require('gitlab.lib.npm')

-- Lua module: gitlab.health
local M = {}

local function _check_node_version(cmd) --{{{
  local node = cmd[1]
  local job, err = require('gitlab.lib.jobs').start_wait({ node, '--version' }, {})
  if err then
    vim.health.error('Unable to run `' .. node .. ' --version`\n' .. err)
  end

  vim.health.ok('Node.js: ' .. job.stdout)
end
--}}}

local function _check_npm_ls() --{{{
  local npm_ls = npm('ls', '--json')
  vim.health.info('Working directory: ' .. npm_ls.cwd)
  local job, err = npm_ls.exec()
  if job then
    local out = vim.json.decode(job.stdout)
    local dependencies = out and out['dependencies'] or {}
    local package = dependencies['@gitlab-org/gitlab-lsp']
    local npm_install = npm('install')
    local advice = {
      string.format(
        'Install the GitLab Language Server via package registry:\n\t\tcd %s\n\t\t%s',
        npm_install.cwd,
        vim.fn.join(npm_install.cmd)
      ),
      'For more information review https://gitlab.com/gitlab-org/editor-extensions/gitlab.vim#troubleshooting',
    }
    if not package then
      local msg = string.format('$ %s', vim.fn.join(npm_ls.cmd), {
        'Unexpected response',
        string.format('STDOUT: %s', job.stdout),
        string.format('STDERR: %s', job.stderr),
      })
      vim.health.error(msg, advice)
      return
    end

    local has_problems = package.problems and #package.problems > 0
    if has_problems then
      advice = vim.tbl_flatten({ package.problems, advice })
    end

    if package.version and has_problems then
      vim.health.warn(
        string.format('@gitlab-org/gitlab-lsp installed (v%s)', package.version),
        advice
      )
    elseif package.version then
      vim.health.ok(string.format('@gitlab-org/gitlab-lsp installed (v%s)', package.version))
    elseif package.missing then
      vim.health.error('@gitlab-org/gitlab-lsp missing', advice)
    else
      local msg = string.format('$ %s', vim.fn.join(npm_ls.cmd))
      vim.health.error(msg, advice)
    end
  end

  if err then
    vim.health.error(err)
  end
end --}}}

local function _check_npm_version() --{{{
  local npm_version = npm('--version')
  local job, err = npm_version.exec()
  if err then
    vim.health.error('npm not found in PATH')
  else
    vim.health.ok('npm@' .. job.stdout)
  end
end --}}}

M.check = function()
  local lsp_server = require('gitlab.lsp.server').new()
  local lsp_cmd = lsp_server:cmd()

  vim.health.start('Language Server')

  if not lsp_server:is_installed() then
    vim.health.error('Not found')
  end

  if not lsp_server:is_executable() then
    vim.health.error('Not executable')
  end

  if lsp_server:is_node() then
    vim.health.ok('Using gitlab-lsp package')
    vim.health.start('Runtime')
    _check_node_version(lsp_cmd)
    _check_npm_version()
    _check_npm_ls()
  else
    vim.health.warn('Using a user-defined language server executable', {
      'Prefer the gitlab-lsp npm package where possible.',
    })
  end
end

return M
