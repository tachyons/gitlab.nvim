describe('gitlab.utils', function()
  describe('merge', function()
    local merge = require('gitlab.utils').merge

    it('returns a new table', function()
      -- given
      local original = { option = 'original value' }
      local expected = { option = 'expected value' }

      -- when
      local merged = merge(original, expected)

      -- then
      assert.are.same(expected.option, merged.option)
      assert.are.Not.same(original.option, expected.option)
      assert.are.Not.same(original.option, merged.option)
    end)
  end)
end)
