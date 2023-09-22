local stub_table = require('spec.helpers.stub_table')

describe('spec.helpers.stub_table', function()
  it('cannot be created without a table', function()
    -- given
    assert.has.error(function()
      stub_table()
    end)
  end)

  it('cannot be created with a nil table', function()
    -- given
    assert.has.error(function()
      stub_table(nil)
    end)
  end)

  it('keeps unspecified key/value pairs', function()
    -- given
    local tbl = { existing = 'existing' }

    -- when
    stub_table(tbl)

    -- then
    assert.is.equal('existing', tbl.existing)
  end)

  it('stubs key/value pairs', function()
    -- given
    local tbl = { existing = 'existing' }

    -- when
    stub_table(tbl, {
      expected = 'expected',
    })

    -- then
    assert.is.equal('existing', tbl.existing)
  end)

  it('stubs key/value pairs of an empty table stub', function()
    -- given
    local tbl = { existing = 'existing' }

    -- when
    local expected_stub = stub_table(tbl)
    local actual_stub = stub_table(tbl, { expected = 'expected' })

    -- then
    assert.is.equal('existing', tbl.existing)
    assert.is.equal('expected', tbl.expected)
    assert.is.equal(expected_stub, actual_stub)
  end)

  it('stubs key/value pairs of a table stub', function()
    -- given
    local tbl = { existing = 'existing' }

    -- when
    local expected_stub = stub_table(tbl, {
      first = 'stubbed on create',
      stubbed_twice = 'stubbed once',
    })
    local actual_stub = stub_table(tbl, {
      second = 'stubbed on cache hit',
      existing = 'existing was stubbed',
      stubbed_twice = 'stubbed twice',
    })

    -- then
    assert.is.equal('existing was stubbed', tbl.existing)
    assert.is.equal('stubbed on create', tbl.first)
    assert.is.equal('stubbed on cache hit', tbl.second)
    assert.is.equal('stubbed twice', tbl.stubbed_twice)
    assert.is.equal(expected_stub, actual_stub)
  end)

  describe('.stub(key, value)', function()
    it('should override an existing key', function()
      -- given
      local tbl = { existing = 'existing' }

      -- when
      stub_table(tbl).stub('existing', 'stubbed')

      -- then
      assert.is.equal('stubbed', tbl.existing)
    end)

    it('should set a new key', function()
      -- given
      local tbl = { existing = 'existing' }

      -- when
      stub_table(tbl).stub('unset', 'stubbed')

      -- then
      assert.is.equal('existing', tbl.existing)
      assert.is.equal('stubbed', tbl.unset)
    end)
  end)

  describe('revert()', function()
    it('should support being reverted', function()
      -- given
      local tbl = { existing = 'existing' }
      stub_table(tbl).stub('existing', 'new value')

      -- when
      stub_table(tbl).revert()

      -- then
      assert.is.equal('existing', tbl.existing)
    end)
  end)
end)
