return {
  bool = function(name, default)
    default = default == true
    local value = vim.env[name]

    local falsy_values = { 'false', 'f', '0' }
    for _, falsy in ipairs(falsy_values) do
      if value == falsy then
        return false
      end
    end

    local truthy_values = { 'true', 't', '1' }
    for _, truthy in ipairs(truthy_values) do
      if value == truthy then
        return true
      end
    end

    vim.validate({
      { value, { 'boolean', 'nil' } },
    })

    return default
  end,
}
