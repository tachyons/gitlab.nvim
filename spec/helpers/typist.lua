local function type_seq(name)
  local seq = '<' .. name .. '>'
  local keys = vim.api.nvim_replace_termcodes(seq, true, false, true)
  vim.api.nvim_feedkeys(keys, 't', false)
end

local keyboard = {
  ctrl = function(key)
    type_seq('C-' .. key)
  end,
}

return {
  under_insert_mode = function(fn)
    vim.api.nvim_feedkeys('i', 't', true)

    fn(keyboard)

    -- NOTE: We _must_ execute commands until typeahead is empty when running headlessly.
    vim.api.nvim_feedkeys('', 'x', true)
  end,
  under_normal_mode = function(fn)
    vim.api.nvim_feedkeys('', 't', true)

    fn(keyboard)

    -- NOTE: We _must_ execute commands until typeahead is empty when running headlessly.
    vim.api.nvim_feedkeys('', 'x', true)
  end,
}
-- vi: set fdm=marker :
