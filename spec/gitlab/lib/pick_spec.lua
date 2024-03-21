local pick = require('gitlab.lib.pick')

describe('pick', function()
  it('picks nested values', function()
    local tbl = { picks = { nested = { values = 'nested value' } } }

    assert.equal('nested value', pick(tbl, { 'picks', 'nested', 'values' }))
  end)

  it('picks nested values by index', function()
    local tbl = { { 'first', { 'first (nested)', 'second (nested)', 'nested value' } } }

    assert.equal('nested value', pick(tbl, { 1, 2, 3 }))
  end)

  it('picks nested values by mixed key s', function()
    local tbl = { first = { 1, { third = { 'nested value' } } } }

    assert.equal('nested value', pick(tbl, { 'first', 2, 'third', 1 }))
  end)

  it('picks top level values by index', function()
    local tbl = { 'top level value' }

    assert.equal('top level value', pick(tbl, { 1 }))
  end)

  it('picks top level values by string key', function()
    local tbl = { existing_key = 'top level value' }

    assert.equal('top level value', pick(tbl, { 'existing_key' }))
  end)

  it('returns nil for a missing top level', function()
    local tbl = {}

    assert.equal(nil, pick(tbl, { 'missing_key' }))
  end)

  it('returns nil for a missing nested given extra keys', function()
    local tbl = { existing_key = {} }

    assert.equal(nil, pick(tbl, { 'existing_key', 'multiple', 'missing', 'keys' }))
  end)

  it('returns nil for a null json nested given extra keys', function()
    local tbl = vim.fn.json_decode('{"existing_key": { "multiple": null }}')

    assert.equal(nil, pick(tbl, { 'existing_key', 'multiple', 'missing', 'keys' }))
  end)

  it('returns nil for a vim.NIL nested given extra keys', function()
    local tbl = { existing_key = { multiple = vim.NIL } }

    assert.equal(nil, pick(tbl, { 'existing_key', 'multiple', 'missing', 'keys' }))
  end)

  it('returns nil for a missing nested', function()
    local tbl = { existing_key = {} }

    assert.equal(nil, pick(tbl, { 'existing_key', 'missing_key' }))
  end)

  it('returns nil for null json value', function()
    local tbl = vim.fn.json_decode('{"existing_key": null}')

    assert.equal(nil, pick(tbl, { 'existing_key' }))
  end)

  it('returns nil for vim.NIL value', function()
    local tbl = { existing_key = vim.NIL }

    assert.equal(nil, pick(tbl, { 'existing_key' }))
  end)
end)
