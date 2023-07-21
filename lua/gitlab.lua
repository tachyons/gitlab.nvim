local gitlab = {
  initialized = false,
  globals = require('gitlab.globals'),
  defaults = {
    url = 'https://gitlab.com',
    logging = {
      debug = vim.env.GITLAB_VIM_DEBUG == '1',
      enabled = vim.env.GITLAB_VIM_LOGGING ~= '0',
    },
    statusline = {},
    code_suggestions = {
      auto_filetypes = {
        'python',
        'ruby',
      },
      enabled = true,
      fix_newlines = true,
      langauge_server_version = nil,
      lsp_binary_path = vim.env.GITLAB_VIM_LSP_BINARY_PATH,
    },
  },
}

function gitlab.url()
  return vim.env.GITLAB_VIM_URL or gitlab.options.url
end

function gitlab.init(options)
  if not gitlab.initialized then
    gitlab.options = vim.tbl_deep_extend('force', gitlab.defaults, options)
    gitlab.options.code_suggestions = vim.tbl_deep_extend(
      'force',
      gitlab.defaults.code_suggestions,
      gitlab.options.code_suggestions
    )
  end

  gitlab.initialized = true

  if not gitlab.logging then
    gitlab.logging = require('gitlab.logging')
  end

  if not gitlab.statusline then
    gitlab.statusline = require('gitlab.statusline')
  end

  if not gitlab.code_suggestions then
    gitlab.code_suggestions = require('gitlab.code_suggestions')
  end

  return gitlab
end

function gitlab.setup(options)
  gitlab.init(options)

  gitlab.logging.setup(gitlab.options.logging)
  gitlab.logging.info('Starting up...')

  if gitlab.options.code_suggestions.enabled then
    gitlab.code_suggestions.setup(
      gitlab.url(),
      gitlab.logging,
      gitlab.statusline,
      gitlab.options.code_suggestions
    )
  else
    gitlab.statusline.update_status_line(gitlab.globals.GCS_UNAVAILABLE)
  end
end

return gitlab
