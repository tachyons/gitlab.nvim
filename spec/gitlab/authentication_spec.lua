describe('gitlab.authentication', function()
  local authentication = require('gitlab.authentication')
  local match = require('luassert.match')
  local stub = require('luassert.stub')

  describe('setup', function()
    before_each(function()
      stub(vim.api, 'nvim_create_user_command')
    end)

    after_each(function()
      vim.api.nvim_create_user_command:revert()
    end)

    it('registers GitLabRegisterToken user command', function()
      -- when
      authentication.setup{}

      -- then
      assert.stub(vim.api.nvim_create_user_command).was.called_with('GitLabRegisterToken', match._, match._)
    end)
  end)

  describe('Vim user commands', function()
    describe('GitLabRegisterToken', function()
      before_each(function()
        stub(vim, 'notify')
        stub(vim.api, 'nvim_parse_cmd')
        stub(vim.fn, 'system')
        stub(vim.ui, 'input')
        authentication.setup{}
      end)

      after_each(function()
        vim.api.nvim_parse_cmd:revert()
        vim.fn.system:revert()
        vim.ui.input:revert()
        vim.notify:revert()
      end)

      it('has no arguments', function()
          -- when
          local status, err = pcall(function() vim.cmd.GitLabRegisterToken('glpat-deadb33f') end)


          -- then
          assert.False(string.find(err, 'Wrong number of arguments$') == nil)
          assert.same(false, status)
      end)
    end)
  end)
end)
