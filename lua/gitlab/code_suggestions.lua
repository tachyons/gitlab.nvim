local code_suggestions = {}

-- TODO: Add specs for different code branches.
function code_suggestions.start()
  -- TODO: Check authenticated status before proceeding
  if not code_suggestions.authenticated then
    vim.notify('GitLab Code Suggestions unavailable.', vim.log.levels.ERROR)
    return
  end

  vim.notify('GitLab Code Suggestions started.')

  -- TODO: Start lsp with user configuration.
end

function code_suggestions.setup(options)
  code_suggestions.options = options or {}
  if not code_suggestions.options.enabled then
    vim.notify('GitLab Code Suggestions is not enabled skipping setup.', vim.log.levels.ERROR)
    return
  end

  vim.api.nvim_create_user_command("GitLabCodeSuggestionsStart", code_suggestions.start, {})
end

return code_suggestions
