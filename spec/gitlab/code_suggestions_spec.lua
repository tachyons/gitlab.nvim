local match = require('luassert.match')
local stub = require('luassert.stub')

describe('gitlab.code_suggestions', function()
  local code_suggestions = require('gitlab/code_suggestions')

  describe('setup', function()
    before_each(function()
      -- TODO: Remove if we move to a service for checking authn status
      code_suggestions.authenticated = true

      stub(vim.api, "nvim_create_user_command")
    end)

    after_each(function()
      vim.api.nvim_create_user_command:revert()
    end)

    it('registers GitLabCodeSuggestions user commands', function()
      code_suggestions.setup({ enabled = true })

      assert.stub(vim.api.nvim_create_user_command).was.called_with("GitLabCodeSuggestionsStart", match._, match._)
    end)

    it('skips GitLabCodeSuggestions user commands', function()
      code_suggestions.setup({ enabled = false })

      assert.stub(vim.api.nvim_create_user_command).was_not.called_with("GitLabCodeSuggestionsStart", match._, match._)
    end)
  end)
end)
