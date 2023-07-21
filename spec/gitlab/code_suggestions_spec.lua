local match = require('luassert.match')
local mock = require('luassert.mock')
local stub = require('luassert.stub')

describe('gitlab.code_suggestions', function()
  local code_suggestions = require('gitlab.code_suggestions')
  local logging = require('gitlab.logging')
  local statusline = require('gitlab.statusline')
  local utils_stub = mock(require('gitlab.utils'), true)

  local stubbed_utils_print_output = ''

  before_each(function()
    stub(vim.fn, 'system')
    logging.setup({ enabled = false })

    utils_stub.user_data_path = function()
      return '/fake'
    end
    utils_stub.current_os = function()
      return 'fakeOS'
    end
    utils_stub.current_arch = function()
      return 'fakeArch'
    end
    utils_stub.print = function(_str)
      return nil
    end
    utils_stub.path_exists = function(_path)
      return true
    end
    utils_stub.exec_cmd = function(_cmd, fn)
      local result = { exit_code = 0, stdout = stubbed_utils_print_output, stderr = '', msg = '' }
      fn(result)
    end
  end)

  after_each(function()
    mock.revert(utils_stub)
    vim.fn.system:revert()
    code_suggestions._checked_pat = nil
  end)

  describe('setup', function()
    before_each(function()
      stub(vim.api, 'nvim_create_user_command')
    end)

    after_each(function()
      vim.api.nvim_create_user_command:revert()
    end)

    it('configures logging', function()
      code_suggestions.setup(logging, statusline, {})

      assert.same(code_suggestions.logging, logging)
    end)

    it('registers GitLabCodeSuggestions user commands', function()
      code_suggestions.setup(logging, statusline, { enabled = true })

      assert
        .stub(vim.api.nvim_create_user_command).was
        .called_with('GitLabCodeSuggestionsStart', match._, match._)
    end)

    it('skips GitLabCodeSuggestions user commands', function()
      code_suggestions.setup(logging, statusline, { enabled = false })

      assert
        .stub(vim.api.nvim_create_user_command).was_not
        .called_with('GitLabCodeSuggestionsStart', match._, match._)
    end)
  end)

  describe('lsp_binary_path', function()
    it('returns full path to the LSP binary', function()
      assert.equal(
        '/fake/gitlab-code-suggestions-language-server-experiment-fakeOS-fakeArch',
        code_suggestions.lsp_binary_path()
      )
    end)
  end)

  describe('token_check_cmd', function()
    it('returns the token check command', function()
      assert.same({
        '/fake/gitlab-code-suggestions-language-server-experiment-fakeOS-fakeArch',
        'token',
        'check',
      }, code_suggestions.token_check_cmd())
    end)
  end)

  describe('check_personal_access_token', function()
    it('calls the LSP binary and checks if the token is enabled and has correct scopes', function()
      assert.equal(true, code_suggestions.check_personal_access_token())
    end)
  end)
end)
