describe('gitlab.version', function()
  local version = require('gitlab.version')

  describe('version', function()
    it('returns 0.1.0', function()
      assert.are.equal("0.1.0", version.version())
    end)
  end)
end)
