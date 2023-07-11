local mock = require('luassert.mock')
local stub = require('luassert.stub')

describe('gitlab.authentication', function()
  local authentication = require('lua.gitlab.authentication')

  local logging = require('lua.gitlab.logging')
  local statusline = require('lua.gitlab.statusline')
  local utils_stub = mock(require('lua.gitlab.utils'), true)

  local stubbed_utils_print_output = ""
  local captured_utils_print_output = ""

  before_each(function()
    logging.setup({ enabled = false })

    utils_stub.user_data_path = function() return "/fake" end
    utils_stub.current_os = function() return "fakeOS" end
    utils_stub.current_arch = function() return "fakeArch" end
    utils_stub.print = function(str) captured_utils_print_output = str ; return nil end
    utils_stub.path_exists = function(_path) return true end
    utils_stub.exec_cmd = function(_cmd, fn)
      local result = { exit_code = 0, stdout = stubbed_utils_print_output, stderr = "", msg = "" }
      fn(result)
    end
  end)

  after_each(function()
    mock.revert(utils_stub)
  end)

  describe('setup', function()
    it('configures logging', function()
      authentication.setup(logging)

      assert.same(authentication.logging, logging)
    end)
  end)

  describe('register', function()
    it('calls check_token()', function()
      stub(authentication, "check_token")

      authentication.register()

      assert.stub(authentication.check_token).was.called()

      authentication.check_token:revert()
    end)
  end)

  describe('lsp_binary_path', function()
    it('returns full path to the LSP binary', function()
      assert.equal("/fake/gitlab-code-suggestions-language-server-experiment-fakeOS-fakeArch",
        authentication.lsp_binary_path())
    end)
  end)

  describe('token_check_cmd', function()
    it('returns the token check command', function()
      assert.same({ "/fake/gitlab-code-suggestions-language-server-experiment-fakeOS-fakeArch",
        "token", "check" }, authentication.token_check_cmd())
    end)
  end)

  describe('check_token', function()
    it('calls the LSP binary and checks if the token is enabled and has correct scopes', function()
      authentication.logging = logging

      stubbed_utils_print_output = "fake output"

      authentication.check_token(statusline)

      assert.equal(stubbed_utils_print_output, captured_utils_print_output)
    end)
  end)
end)
