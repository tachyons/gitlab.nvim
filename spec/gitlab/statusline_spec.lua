describe('gitlab.statusline', function()
  local statusline = require('gitlab.statusline')

  before_each(function() end)

  describe('status_line_for', function()
    it('returns a suitable status line for vim.opt.statusline', function()
      assert.are.equal(
        '%-5{%v:lua.string.upper(v:lua.vim.fn.mode())%}%-.16t[%n] %-m %y [GCS:unknown] %=%10([%l/%L%)]',
        statusline.status_line_for()
      )
    end)
  end)
end)
