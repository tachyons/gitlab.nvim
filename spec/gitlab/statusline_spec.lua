describe('gitlab.statusline', function()
  local globals = require('gitlab.globals')
  local statusline = require('gitlab.statusline')

  before_each(function()
    statusline.setup({ enabled = true })
  end)

  after_each(function()
    vim.o.statusline = nil
  end)

  describe('status_line_for', function()
    it('returns a suitable template for statusline', function()
      assert.are.equal(
        '%-5{%v:lua.string.upper(v:lua.vim.fn.mode())%}%-.16t[%n] %-m %y [GCS:unknown] %=%10([%l/%L%)]',
        statusline.status_line_for()
      )
    end)
  end)

  describe('update_status_line', function()
    it('set the statusline option', function()
      statusline.setup({ enabled = true })

      local actual = statusline.update_status_line(globals.GCS_UNKNOWN_TEXT)

      assert.are.equal(true, actual)
      assert.are.equal(
        '%-5{%v:lua.string.upper(v:lua.vim.fn.mode())%}%-.16t[%n] %-m %y [GCS:unknown] %=%10([%l/%L%)]',
        vim.o.statusline
      )
    end)

    it('does not set the statusline option', function()
      statusline.setup({ enabled = false })

      local actual = statusline.update_status_line(globals.GCS_UNKNOWN_TEXT)

      assert.are.equal(false, actual)
      assert.are.equal('', vim.o.statusline)
    end)
  end)
end)
