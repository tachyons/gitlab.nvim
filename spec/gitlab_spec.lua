local match = require('luassert.match')
local stub = require('luassert.stub')

describe('gitlab', function()
  local gitlab = require('gitlab')

  local utils = require('gitlab.utils')
  local code_suggestions = require('gitlab.code_suggestions')

  before_each(function()
    gitlab.initialized = false
    gitlab.options = gitlab.defaults
    gitlab.options.logging.enabled = false
  end)

  describe('init', function()
    it('happens once', function()
      local expected = { old_option = 'expected value' }
      local unexpected = { old_option = 'unexpected value', new_option = true }

      gitlab.init(expected)
      gitlab.init(unexpected)

      assert.are.same(expected.old_option, gitlab.options.old_option)

      assert.is.Nil(gitlab.options.new_option)
    end)

    it('initializes default values when no options are specified', function()
      gitlab.init({})

      assert.are.same(gitlab.defaults, gitlab.options)
    end)
  end)

  describe('url', function()
    describe('default', function()
      it('returns https://gitlab.com', function()
        local expected = 'https://gitlab.com'

        gitlab.init({})

        assert.are.same(expected, gitlab.url())
      end)
    end)

    describe('customized', function()
      it('supports url being set via options', function()
        local expected = 'https://options-based.gitlab.instance'

        gitlab.init({
          url = expected,
        })

        assert.are.same(expected, gitlab.url())
      end)

      it('supports url being set via the GITLAB_VIM_URL env var', function()
        local original = vim.env.GITLAB_VIM_URL
        local expected = 'https://env-based.gitlab.instance'

        vim.env.GITLAB_VIM_URL = expected

        gitlab.init({})

        assert.are.same(expected, gitlab.url())

        vim.env.GITLAB_VIM_URL = original
      end)
    end)
  end)

  describe('setup', function()
    before_each(function()
      stub(utils, 'print')
      stub(code_suggestions, 'check_personal_access_token')
      stub(vim.api, 'nvim_create_user_command')
    end)

    after_each(function()
      utils.print:revert()
      code_suggestions.check_personal_access_token:revert()
      vim.api.nvim_create_user_command:revert()
    end)

    it('registers default vim commands', function()
      gitlab.setup({})

      assert
        .stub(vim.api.nvim_create_user_command).was
        .called_with('GitLabBootstrapCodeSuggestions', match._, match._)
      assert
        .stub(vim.api.nvim_create_user_command).was
        .called_with('GitLabCodeSuggestionsStart', match._, match._)
      assert
        .stub(vim.api.nvim_create_user_command).was
        .called_with('GitLabCodeSuggestionsStop', match._, match._)
    end)
  end)
end)
