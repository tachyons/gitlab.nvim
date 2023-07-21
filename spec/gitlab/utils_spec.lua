local mock = require('luassert.mock')

describe('gitlab.utils', function()
  local utils = require('gitlab.utils')

  local utils_vim_stub = mock(require('gitlab.utils_vim'), true)

  local stubbed_current_os = ''
  local stubbed_current_arch = ''
  local stubbed_path_exists = ''
  local stubbed_jobstart_cmd = ''
  local stubbed_jobstart_stdout = ''

  local function tables_match(a, b)
    return table.concat(a) == table.concat(b)
  end

  before_each(function()
    utils_vim_stub.fn = {
      stdpath = function()
        return '/fake/data/path'
      end,
      system = function(cmd)
        if tables_match(cmd, { 'uname', '-s' }) then
          return stubbed_current_os
        elseif tables_match(cmd, { 'uname', '-m' }) then
          return stubbed_current_arch
        else
          return 'unknown'
        end
      end,
      jobstart = function(cmd, _options)
        if cmd == stubbed_jobstart_cmd then
          return { exit_code = 0, stdout = stubbed_jobstart_stdout, stderr = '', msg = '' }
        else
          return { exit_code = 1, stdout = 'bad stdout', stderr = 'bad stderr', msg = 'bad msg' }
        end
      end,
    }

    utils_vim_stub.loop = {
      fs_stat = function(path)
        if path == stubbed_path_exists then
          return true
        else
          return false
        end
      end,
    }
  end)

  after_each(function()
    mock.revert(utils_vim_stub)
  end)

  describe('user_data_path', function()
    it("returns the user's data path", function()
      assert.equal('/fake/data/path', utils.user_data_path())
    end)
  end)

  describe('formatted_line_for_print', function()
    it('prints a formatted line', function()
      assert.equal('[gitlab.vim] test', utils.formatted_line_for_print('test'))
    end)
  end)

  describe('current_os', function()
    it('returns the current OS, downcased', function()
      stubbed_current_os = 'fakeOS'

      assert.equal('fakeos', utils.current_os())
    end)
  end)

  describe('current_arch', function()
    it('returns the current CPU architecture, downcased', function()
      stubbed_current_arch = 'fakeArch'

      assert.equal('fakearch', utils.current_arch())
    end)
  end)

  describe('path_exists', function()
    it('returns true if path exists', function()
      stubbed_path_exists = '/fake/path'

      assert.True(utils.path_exists(stubbed_path_exists))
    end)
  end)

  describe('exec_cmd', function()
    it('returns a table with exit code, stdout, stderr and optional msg', function()
      mock.revert(utils_vim_stub)

      stubbed_jobstart_cmd = "echo -n 'true'"
      stubbed_jobstart_stdout = 'true'

      local expected = { exit_code = 0, stdout = stubbed_jobstart_stdout, stderr = '', msg = '' }

      local fn = function(result)
        local assert = require('luassert')

        assert.same(expected, result)
      end

      utils.exec_cmd(stubbed_jobstart_cmd, fn)
    end)
  end)
end)
