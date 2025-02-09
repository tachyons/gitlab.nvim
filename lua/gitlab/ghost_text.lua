local M = {
  -- Used for dependency injection
  vim = vim,
}
local ns
local last_suggestion
local update_timer = nil
local debounce_delay = 80 -- milliseconds
local ghost_text_extmark_id = nil
local suggestion_shown = nil
local group = 'GitLabGhostText'

local function setup_highlights()
  M.vim.api.nvim_set_hl(0, group, { fg = '#808080', italic = true })
  M.vim.api.nvim_set_hl(0, 'GitLabIcon', { fg = '#FC6D26' })
end

local function debounce(func)
  return function(...)
    local args = { ... }
    if update_timer then
      M.vim.fn.timer_stop(update_timer)
    end
    update_timer = M.vim.fn.timer_start(debounce_delay, function()
      func(unpack(args))
      update_timer = nil
    end)
  end
end

M.setup = function(lsp_client, cfg)
  if not cfg or not cfg.enabled then
    return
  end

  setup_highlights()
  M.lsp_client = lsp_client
  M.enabled = true

  M.edit_counter = 0
  ns = M.vim.api.nvim_create_namespace('gitlab.GhostText')

  local augroup_id = M.vim.api.nvim_create_augroup(group, { clear = true })

  M.vim.api.nvim_create_autocmd('InsertEnter', {
    group = augroup_id,
    callback = function()
      require('gitlab.ghost_text').on_insert_enter()
    end,
  })
  M.vim.api.nvim_create_autocmd('InsertLeave', {
    group = augroup_id,
    callback = function()
      require('gitlab.ghost_text').on_insert_leave()
    end,
  })
  M.vim.api.nvim_create_autocmd('TextChangedI', {
    group = augroup_id,
    callback = function()
      require('gitlab.ghost_text').on_text_changed()
    end,
  })
  M.vim.api.nvim_create_autocmd('CursorMovedI', {
    group = augroup_id,
    callback = function()
      require('gitlab.ghost_text').on_cursor_moved()
    end,
  })

  if cfg.toggle_enabled then
    M.vim.keymap.set('i', cfg.toggle_enabled, function()
      M.toggle_enabled()
    end)
  end
  if cfg.accept_suggestion then
    M.vim.keymap.set('i', cfg.accept_suggestion, function()
      M.insert_ghost_text()
    end)
  end
  if cfg.clear_suggestions then
    M.vim.keymap.set('i', cfg.clear_suggestions, function()
      M.clear_all_ghost_text()
    end)
  end
end

local function create_or_update_extmark(lines)
  local bufnr = M.vim.api.nvim_get_current_buf()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))

  local virt_text = { { lines[1], group } }
  local virt_lines = {}
  for i = 2, #lines do
    table.insert(virt_lines, { { lines[i], group } })
  end

  local opts = {
    virt_text = virt_text,
    virt_text_pos = 'overlay',
    virt_lines = virt_lines,
    virt_lines_above = false,
    hl_mode = 'combine',
    priority = 100,
  }

  if ghost_text_extmark_id then
    M.vim.api.nvim_buf_del_extmark(bufnr, ns, ghost_text_extmark_id)
  end
  ghost_text_extmark_id = M.vim.api.nvim_buf_set_extmark(bufnr, ns, row - 1, col, opts)
end

M.clear_all_ghost_text = function()
  M.clear_ghost_text()

  if ns then
    local bufnr = M.vim.api.nvim_get_current_buf()
    M.vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  end
end

M.clear_ghost_text = function()
  if ns and ghost_text_extmark_id then
    local bufnr = M.vim.api.nvim_get_current_buf()
    M.vim.api.nvim_buf_del_extmark(bufnr, ns, ghost_text_extmark_id)
    ghost_text_extmark_id = nil
  end
  suggestion_shown = false
end

M.increment_edit_counter = function()
  M.edit_counter = M.edit_counter + 1
end

M.update_ghost_text_with_debounce = debounce(function(edit_counter)
  M.update_ghost_text(edit_counter)
end)

M.update_ghost_text = function(edit_counter)
  if not M.enabled then
    return
  end

  if M.edit_counter ~= edit_counter then
    -- request is stale
    return
  end

  if M.lsp_client == nil or not ns then
    return
  end

  local client_id = M.lsp_client.client_id
  local client = M.vim.lsp.get_client_by_id(client_id)
  local bufnr = M.vim.api.nvim_get_current_buf()
  local params = M.vim.tbl_extend('force', { context = {} }, M.vim.lsp.util.make_position_params())

  M.is_requesting = true

  client.request('textDocument/inlineCompletion', params, function(err, result)
    if M.edit_counter ~= edit_counter then
      -- completion is stale
      return
    end

    M.is_requesting = false
    if err then
      M.clear_ghost_text()
      return
    end

    if not result or #result.items == 0 then
      M.clear_ghost_text()
      return
    end

    M.display_suggestion(result.items)
  end, bufnr)
end

M.display_suggestion = function(suggestions)
  suggestion_shown = true
  if #suggestions == 0 then
    return
  end

  last_suggestion = suggestions[1].insertText
  local lines = M.vim.split(last_suggestion, '\n')
  create_or_update_extmark(lines)
end

M.insert_or_request_ghost_text = function()
  if suggestion_shown then
    M.insert_ghost_text()
  else
    M.update_ghost_text(M.edit_counter)
  end
end

M.insert_ghost_text = function()
  if not suggestion_shown then
    return
  end
  local text_to_insert = last_suggestion
  if not text_to_insert then
    return
  end
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local lines = M.vim.split(text_to_insert, '\n')
  M.vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, lines)
  local new_row = row + #lines - 1
  local new_col = #lines > 1 and #lines[#lines] or (col + #lines[1])
  M.vim.api.nvim_win_set_cursor(0, { new_row, new_col })
  M.clear_ghost_text()
end

M.toggle_enabled = function()
  if M.enabled then
    M.enabled = false
    M.increment_edit_counter()
    M.clear_ghost_text()
  else
    M.enabled = true
    M.update_ghost_text(M.edit_counter)
  end
end

M.on_insert_leave = function()
  M.increment_edit_counter()
  M.clear_ghost_text()
end

M.on_cursor_moved = function()
  M.increment_edit_counter()
  M.clear_ghost_text()
end

M.on_insert_enter = function()
  M.increment_edit_counter()
  M.update_ghost_text(M.edit_counter)
end

M.on_text_changed = function()
  M.increment_edit_counter()

  M.clear_ghost_text()

  M.update_ghost_text_with_debounce(M.edit_counter)
end

return M
