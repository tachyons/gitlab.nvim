describe('gitlab.commands.code_suggestions', function()
  local code_suggestions_commands = require('gitlab.commands.code_suggestions')
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
      stub(vim.api, 'nvim_create_autocmd')
      stub(vim.api, 'nvim_create_user_command')
      stub(vim.keymap, 'set')
    end)

    it('registers vim commands and keymaps', function()
      code_suggestions_commands.create({
        group = 1,
        auth = mock(require('gitlab.authentication.provider.env')),
        workspace = mock(require('gitlab.lsp.workspace')),
      })
      assert.stub(vim.api.nvim_create_autocmd).was.called_with({ 'CompleteDonePre' }, match._)
      assert.stub(vim.api.nvim_create_autocmd).was.called_with({ 'FileType' }, match._)
      assert
        .stub(vim.api.nvim_create_user_command).was
        .called_with('GitLabCodeSuggestionsInstallLanguageServer', match._, match._)
      assert
        .stub(vim.api.nvim_create_user_command).was
        .called_with('GitLabCodeSuggestionsStart', match._, match._)
      assert
        .stub(vim.api.nvim_create_user_command).was
        .called_with('GitLabCodeSuggestionsStop', match._, match._)
      assert
        .stub(vim.keymap.set).was
        .called_with('n', '<Plug>(GitLabToggleCodeSuggestions)', match._, match._)
    end)
  end)
end)
