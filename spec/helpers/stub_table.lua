-- Lua module: spec.helpers.stub_table
local M = {}

local function make_stub(tbl, key, value)
  local old = tbl[key]

  tbl[key] = value

  return {
    -- Example: stub.revert()
    revert = function()
      tbl[key] = old
    end,
  }
end

local function table_stub(tbl)
  local registered = {}
  return {
    -- Example: stub_table(vim.env).revert()
    revert = function()
      for key, stub in pairs(registered) do
        stub.revert()
        registered[key] = nil
      end
    end,
    -- Example: stub('GITLAB_TOKEN', 'glpat-env_before_setup')
    stub = function(key, value)
      local existing = registered[key]
      if existing then
        existing.revert()
        registered[key] = nil
      end

      registered[key] = make_stub(tbl, key, value)
      return registered[key]
    end,
  }
end

local table_stubs = {}
-- Example: stub_table(vim.env, {})
function M.stub_table(tbl, stubs)
  local t = type(tbl)
  local expected = 'table'
  assert(t == expected, 'wrong type "' .. t .. '"')

  local ptr = string.format('%p', tbl)
  if not table_stubs[ptr] then
    table_stubs[ptr] = table_stub(tbl)
  end

  for key, value in pairs(stubs or {}) do
    table_stubs[ptr].stub(key, value)
  end

  return table_stubs[ptr]
end

setmetatable(M, {
  __call = function(_self, ...)
    return M.stub_table(...)
  end,
})

return M
