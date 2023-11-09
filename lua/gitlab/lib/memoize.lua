return function(fn)
  local _called = false
  local _resolved

  return function()
    if not _called then
      _called = true

      local ok, resolved = pcall(fn)
      if ok then
        _resolved = resolved
      else
        error(resolved)
      end
    end

    return _resolved
  end
end
