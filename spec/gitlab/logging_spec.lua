describe('gitlab.logging', function()
  local logging = require('gitlab.logging')

  before_each(function()
    logging.setup({ version = '0.0.0' })
  end)

  describe('format_line', function()
    it('returns a line with timestamp, level, version and msg', function()
      assert.are.equal(
        '1234-56-78 12:34:56: INFO (0.0.0): test',
        logging.format_line('test', 'INFO', '1234-56-78 12:34:56')
      )
    end)
  end)
end)
