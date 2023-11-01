local busted = require('plenary.busted')
local conditions = require('spec.helpers.conditions')

-- luacheck: globals after_each before_each describe it

local guard_each = function(busted_fn, condition)
  vim.validate({
    busted_fn = { busted_fn, 'function' },
    condition = { condition, 'table' },
    ['condition.met'] = { condition and condition.met, 'function' },
    ['condition.unmet'] = { condition and condition.unmet, 'function' },
  })

  return function(fn)
    busted_fn(function()
      if condition.met() then
        fn()
      end
    end)
  end
end

local guard_it = function(condition)
  vim.validate({
    condition = { condition, 'table' },
    ['condition.met'] = { condition and condition.met, 'function' },
    ['condition.unmet'] = { condition and condition.unmet, 'function' },
  })

  return function(desc, fn)
    busted.it(desc, function()
      if condition.met() then
        fn()
      else
        condition.unmet()
      end
    end)
  end
end

local guard_describe
---@param desc string: options to pass to the picker
---@param condition table|nil:  (default: See `run_integration_tests`)
---@field met function: met() -> boolean. Whether this test group should run.
---@field unmet function: unmet() -> nil. Function to run instead of executing this test if this condition was unmet.
---@param fn function: The body of this test group.
guard_describe = function(desc, condition, fn)
  if fn == nil then
    fn = condition
    condition = conditions.run_integration_tests
  end

  vim.validate({
    desc = { desc, 'string' },
    condition = { condition, 'table' },
    ['condition.met'] = { condition and condition.met, 'function' },
    ['condition.unmet'] = { condition and condition.unmet, 'function' },
    fn = { fn, 'function' },
  })

  -- Guard execution of test body based on conditions.
  after_each = guard_each(busted.after_each, condition)
  before_each = guard_each(busted.before_each, condition)
  describe = guard_describe
  it = guard_it(condition)

  busted.describe(desc, fn)

  after_each = busted.after_each
  before_each = busted.before_each
  describe = busted.describe
  it = busted.it
end

return guard_describe
-- vi: set fdm=marker :
