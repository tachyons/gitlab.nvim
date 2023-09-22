local assert = require('luassert.assert')
local say = require('say')

local function register_say(namespace, kwargs)
  local positive_key = namespace .. '.positive'
  local negative_key = namespace .. '.negative'

  say:set(positive_key, kwargs.positive)
  say:set(negative_key, kwargs.negative)

  return positive_key, negative_key
end

local function register_assertion(name, kwargs, assertion)
  local namespace = 'assertion.' .. name
  local positive, negative = register_say(namespace, kwargs)

  assert:register('assertion', name, assertion, positive, negative)
end

register_assertion('registered_user_command', {
  positive = 'Expected user command %s to be registered',
  negative = 'Expected user command %s to not have been registered',
}, function(_state, arguments)
  return vim.cmd[arguments[1]] ~= nil
end)

register_assertion('has_type', {
  positive = '',
  negative = '',
}, function(_state, arguments)
  return type(arguments[1]) == arguments[2]
end)

return assert
