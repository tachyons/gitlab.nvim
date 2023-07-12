local match = require('luassert.match')
local stub = require('luassert.stub')

describe('gitlab', function()
  local gitlab = require('gitlab')

  local authentication = require('gitlab/authentication')

  before_each(function()
    gitlab.state.initialized = false
    gitlab.options = gitlab.defaults
    gitlab.options.logging.enabled = false

    gitlab.authentication = authentication
  end)

  describe('setup', function()
    before_each(function()
      stub(authentication, "register")
      stub(vim.api, "nvim_create_user_command")
    end)

    after_each(function()
      authentication.register:revert()
      vim.api.nvim_create_user_command:revert()
    end)

    it('initializes default values when no options are specified', function()
      gitlab.setup()

      assert.are.same(gitlab.defaults, gitlab.options)
    end)

    it('happens once', function()
      local expected = { old_option = 'expected value' }
      local unexpected = { old_option = 'unexpected value', new_option = true }

      gitlab.setup(expected)
      gitlab.setup(unexpected)

      assert.are.same(expected.old_option, gitlab.options.old_option)

      assert.is.Nil(gitlab.options.new_option)
    end)

    it('registers default vim commands', function()
      gitlab.setup()

      assert.stub(vim.api.nvim_create_user_command).was.called_with("GitLabCodeSuggestionsStart", match._, match._)
      -- assert.stub(vim.api.nvim_create_user_command).was.called_with("GitLabRegisterToken", match._, match._)
    end)
  end)
end)
