local utils = {}

function utils.merge(orig, overrides)
  local merged = {}
  if orig ~= nil then
    for k, v in pairs(orig) do
      merged[k] = v
    end
  end

  if overrides ~= nil then
    for k, v in pairs(overrides) do
      merged[k] = v
    end
  end

  return merged
end

return utils
