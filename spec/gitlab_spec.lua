local match = require('luassert.match')
local stub = require('luassert.stub')

describe('gitlab', function()
  local gitlab = require('lua.gitlab')

  local utils = require('lua.gitlab.utils')
  local authentication = require('lua.gitlab.authentication')

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

  describe('setup', function()
    before_each(function()
      stub(utils, 'print')
      stub(authentication, 'check_token')
      stub(vim.api, 'nvim_create_user_command')
    end)

    after_each(function()
      utils.print:revert()
      authentication.check_token:revert()
      vim.api.nvim_create_user_command:revert()
    end)

    it('registers default vim commands', function()
      gitlab.setup({})

      assert
        .stub(vim.api.nvim_create_user_command).was
        .called_with('GitLabCodeSuggestionsStart', match._, match._)
      -- assert.stub(vim.api.nvim_create_user_command).was.called_with("GitLabRegisterToken", match._, match._)
    end)
  end)
end)
