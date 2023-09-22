describe('gitlab.commands.configure', function()
  local configure_command = require('gitlab.commands.configure')
  local match = require('luassert.match')
  local mock = require('luassert.mock')
  local stub = require('luassert.stub')

  local snapshot
  before_each(function()
    snapshot = assert:snapshot()
  end)

  after_each(function()
    snapshot:revert()
  end)

  describe('create', function()
    before_each(function()
      stub(vim.api, 'nvim_create_user_command')
    end)

    it('registers vim command', function()
      configure_command.create({
        auth = mock(require('gitlab.authentication.provider.env')),
        workspace = mock(require('gitlab.lsp.workspace')),
      })
      assert
        .stub(vim.api.nvim_create_user_command).was
        .called_with('GitLabConfigure', match._, match._)
    end)
  end)
end)
