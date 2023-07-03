describe('gitlab.logging', function()
  local version = require('gitlab.version')
  local logging = require('gitlab.logging')

  describe('format_line', function()
    it('returns a line with timestamp, level, version and msg', function()
      assert.are.equal("1234-56-78 12:34:56: INFO (" .. version.version() .. "): test",
        logging.format_line('test', 'INFO', "1234-56-78 12:34:56"))
    end)
  end)
end)
