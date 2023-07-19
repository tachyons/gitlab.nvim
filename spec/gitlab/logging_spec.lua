describe('gitlab.logging', function()
  local globals = require('gitlab.globals')
  local logging = require('gitlab.logging')
  local original_plugin_version

  before_each(function()
    logging.setup()
    original_plugin_version = globals.PLUGIN_VERSION
    globals.PLUGIN_VERSION = '0.0.0'
  end)

  after_each(function()
    globals.PLUGIN_VERSION = original_plugin_version
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
