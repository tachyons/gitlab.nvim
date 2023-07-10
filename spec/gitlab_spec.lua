describe('gitlab', function()
  local gitlab = require('gitlab')
  local match = require('luassert.match')
  local stub = require('luassert.stub')

  before_each(function()
    gitlab.initialized = false
    gitlab.options = gitlab.defaults
  end)

  describe('init', function()
    it('happens once', function()
      -- given
      local expected = { old_option = 'expected value' }
      local unexpected = { old_option = 'unexpected value', new_option = true }

      -- when
      gitlab.init(expected)
      gitlab.init(unexpected)

      -- then
      assert.are.same(expected.old_option, gitlab.options.old_option)

      assert.is.Nil(gitlab.options.new_option)
    end)

    it('initializes default values when no options are specified', function()
      -- when
      gitlab.init{}

      -- then
      assert.are.same(gitlab.defaults, gitlab.options)
    end)
  end)

  describe('setup', function()
    before_each(function()
      stub(vim.api, "nvim_create_user_command")
    end)

    after_each(function()
      vim.api.nvim_create_user_command:revert()
    end)

    it('registers default vim commands', function()
      -- when
      gitlab.setup{}

      -- then
      assert.stub(vim.api.nvim_create_user_command).was.called_with("GitLabCodeSuggestionsStart", match._, match._)
      assert.stub(vim.api.nvim_create_user_command).was.called_with("GitLabRegisterToken", match._, match._)
    end)
  end)
end)
