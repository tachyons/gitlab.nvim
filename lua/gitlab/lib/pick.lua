local function pick(tbl, keys)
  local value = tbl
  for _, key in ipairs(keys) do
    if value == nil then
      return nil
    end

    value = value[key]
  end

  return value
end

return pick
