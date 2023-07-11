local version = "0.1.2"

local gitlab = {
  initialized = false,
  globals = require('lua.gitlab.globals'),
  defaults = {
    logging = {
      version = version,
      debug = os.getenv("GITLAB_VIM_DEBUG") == "1",
      enabled = os.getenv("GITLAB_VIM_LOGGING") ~= "0",
    },
    statusline = {},
    authentication = {},
    code_suggestions = {
      enabled = true,
      personal_access_token = nil,
    }
  }
}

local merge = require('lua.gitlab.utils').merge

function gitlab.init(options)
  if not gitlab.initialized then
    gitlab.options = merge(gitlab.defaults, options)
    -- TODO: Implement deep merge for table values.
    gitlab.options.code_suggestions = merge(gitlab.defaults.code_suggestions, gitlab.options.code_suggestions)
  end
  gitlab.initialized = true

  if not gitlab.logging then gitlab.logging = require('lua.gitlab.logging') end
  if not gitlab.statusline then gitlab.statusline = require('lua.gitlab.statusline') end
  if not gitlab.authentication then gitlab.authentication = require('lua.gitlab.authentication') end
  if not gitlab.code_suggestions then gitlab.code_suggestions = require('lua.gitlab.code_suggestions') end

  return gitlab
end

function gitlab.setup(options)
  gitlab.init(options)

  gitlab.logging.setup(merge(gitlab.options.logging, {version = version}))
  gitlab.logging.info("Starting up..")

  if gitlab.options.code_suggestions.enabled then
    gitlab.statusline.setup(gitlab.globals.GCS_CHECKING)

    gitlab.code_suggestions.setup(gitlab.options.code_suggestions)

    if gitlab.authentication then
      gitlab.authentication.setup(gitlab.logging)
      gitlab.authentication.register(gitlab.statusline)
    end
  else
    gitlab.statusline.setup(gitlab.globals.GCS_UNAVAILABLE)
  end
end

return gitlab
