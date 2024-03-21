local function pick(tbl, keys)
  local value = tbl
  for _, key in ipairs(keys) do
    if value == vim.NIL then
      return nil
    end

    value = value and value[key]
  end

  if value == vim.NIL then
    return nil
  end

  return value
end

return pick
