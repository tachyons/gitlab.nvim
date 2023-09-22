local statusline = {}

local globals = require('gitlab.globals')

function statusline.status_line_for(state)
  local state_text = state or globals.GCS_UNKNOWN_TEXT

  local mode = '%-5{%v:lua.string.upper(v:lua.vim.fn.mode())%}'
  local file_name = '%-.16t'
  local buf_nr = '[%n]'
  local modified = ' %-m'
  local file_type = ' %y'
  local code_suggestions_state = ' [GCS:' .. state_text .. '] '
  local right_align = '%='
  local line_no = '%10([%l/%L%)]'
  local pct_thru_file = '%5p%%'

  return string.format(
    '%s%s%s%s%s%s%s%s',
    mode,
    file_name,
    buf_nr,
    modified,
    file_type,
    code_suggestions_state,
    right_align,
    line_no,
    pct_thru_file
  )
end

function statusline.state_label_for(state)
  if state == globals.GCS_AVAILABLE_AND_ENABLED then
    return globals.GCS_AVAILABLE_AND_ENABLED_TEXT
  elseif state == globals.GCS_AVAILABLE_BUT_DISABLED then
    return globals.GCS_AVAILABLE_BUT_DISABLED_TEXT
  elseif state == globals.GCS_CHECKING then
    return globals.GCS_CHECKING_TEXT
  elseif state == globals.GCS_INSTALLED then
    return globals.GCS_INSTALLED_TEXT
  elseif state == globals.GCS_UNAVAILABLE then
    return globals.GCS_UNAVAILABLE_TEXT
  elseif state == globals.GCS_UPDATED then
    return globals.GCS_UPDATED_TEXT
  else
    return globals.GCS_UNKNOWN_TEXT
  end
end

function statusline.update_status_line(state)
  local config = require('gitlab.config').current()
  if config.statusline.enabled then
    vim.o.statusline = statusline.status_line_for(statusline.state_label_for(state))
    return true
  end

  return false
end

return statusline
