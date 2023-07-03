local statusline = {}

local function status_line()
  local mode = "%-5{%v:lua.string.upper(v:lua.vim.fn.mode())%}"
  local file_name = "%-.16t"
  local buf_nr = "[%n]"
  local modified = " %-m"
  local file_type = " %y"
  -- TODO: Remove hardcoded 'on'
  local gitlab_code_suggestions_status = " [🔮:on] "
  local right_align = "%="
  local line_no = "%10([%l/%L%)]"
  local pct_thru_file = "%5p%%"

  return string.format(
    "%s%s%s%s%s%s%s%s",
    mode,
    file_name,
    buf_nr,
    modified,
    file_type,
    gitlab_code_suggestions_status,
    right_align,
    line_no,
    pct_thru_file
  )
end

function statusline.setup()
  vim.opt.statusline = status_line()
end

return statusline
