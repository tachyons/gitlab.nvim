local M = {}

local function islist(tbl)
  if vim.islist then
    return vim.islist(tbl)
  end

  return vim.tbl_islist(tbl)
end

--{{{[Validation functions]
function M.is_dict()
  return function(tbl)
    return type(tbl) == 'table' and not islist(tbl)
  end, 'a dict'
end
function M.is_dict_of(value_type)
  return function(tbl)
    if type(tbl) ~= 'table' or islist(tbl) then
      return false
    end

    for key, value in pairs(tbl) do
      if type(key) ~= 'string' or type(value) ~= value_type then
        return false
      end
    end

    return true
  end,
    'a dict of ' .. value_type
end

function M.is_string_list(tbl)
  if type(tbl) ~= 'table' or not islist(tbl) then
    return false
  end

  for _, el in ipairs(tbl) do
    if type(el) ~= 'string' then
      return false
    end
  end

  return true
end
--}}}

local function validate_config(config)
  vim.validate({
    config = { config, 'table', 'expected table with string keys' },
  })

  vim.validate({
    --{{{[Top level options]
    ['code_suggestions'] = { config.code_suggestions, 'table' },
    ['gitlab_url'] = { config.gitlab_url, 'string' },
    --}}}
  })

  vim.validate({
    --{{{[Code Suggestions]
    ['code_suggestions.auto_filetypes'] = {
      config.code_suggestions.auto_filetypes,
      M.is_string_list,
      'expected table with string values',
    },
    ['code_suggestions.enabled'] = { config.code_suggestions.enabled, 'boolean' },
    ['resource_editing.enabled'] = { config.resource_editing.enabled, 'boolean' },
    ['code_suggestions.fix_newlines'] = { config.code_suggestions.fix_newlines, 'boolean' },
    ['code_suggestions.redact_secrets'] = { config.code_suggestions.redact_secrets, 'boolean' },
    --}}}
  })
end

setmetatable(M, {
  __call = function(_self, ...)
    return validate_config(...)
  end,
})

return M
-- vi: set fdm=marker :
