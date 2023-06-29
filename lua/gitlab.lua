local gitlab = {
  initialized = false,
  defaults = {
    statusline = {},
    authentication = {},
    code_suggestions = {
      enabled = true,
      personal_access_token = nil,
    }
  }
}

local merge = require'gitlab.utils'.merge

function gitlab.init(options)
  if not gitlab.initialized then
    gitlab.options = merge(gitlab.defaults, options)
    -- TODO: Implement deep merge for table values.
    gitlab.options.code_suggestions = merge(gitlab.defaults.code_suggestions, gitlab.options.code_suggestions)
  end
  gitlab.initialized = true

  if not gitlab.statusline then
    gitlab.statusline = require 'gitlab.statusline'
  end

  if not gitlab.authentication then
    gitlab.authentication = require'gitlab.authentication'
  end

  if not gitlab.code_suggestions then
    gitlab.code_suggestions = require'gitlab.code_suggestions'
  end

  return gitlab
end

function gitlab.setup(options)
  gitlab.init(options)

  if gitlab.statusline then
    gitlab.statusline.setup(gitlab.options.statusline)
  end

  if gitlab.authentication then
    gitlab.authentication.setup(gitlab.options.authentication)
  end

  if gitlab.options.code_suggestions.enabled then
    gitlab.code_suggestions.setup(gitlab.options.code_suggestions)
  end
end

return gitlab
