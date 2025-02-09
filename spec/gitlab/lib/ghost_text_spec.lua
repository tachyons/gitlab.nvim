local spy = require('luassert.spy')

describe('gitlab.ghost_text', function()
  local ghost_text
  local lsp_client
  local mock_vim

  before_each(function()
    -- Reset the module before each test
    package.loaded['gitlab.ghost_text'] = nil
    ghost_text = require('gitlab.ghost_text')

    -- Stub out all vim APIs we need
    local keymap = {
      set = spy.new(function() end),
    }
    local api = {
      nvim_buf_set_extmark = spy.new(function() end),
      nvim_buf_del_extmark = spy.new(function() end),
      nvim_buf_clear_namespace = spy.new(function() end),
      nvim_get_current_buf = spy.new(function() end),
      nvim_create_namespace = spy.new(function()
        return 123
      end),
      nvim_create_augroup = spy.new(function()
        return 234
      end),
      nvim_create_autocmd = spy.new(function() end),
      nvim_set_hl = spy.new(function() end),
    }
    local lsp = {
      client_id = 1,
      request = spy.new(function() end),
      notify = spy.new(function() end),
      get_client_by_id = spy.new(function()
        return lsp_client
      end),
      util = { make_position_params = spy.new(function()
        return {}
      end) },
    }
    local cmd = spy.new(function() end)
    mock_vim = {
      api = api,
      lsp = lsp,
      cmd = cmd,
      keymap = keymap,
      tbl_extend = spy.new(function() end),
      split = spy.new(function()
        return { 'line 1', 'line 2' }
      end),
    }
    ghost_text.vim = mock_vim

    -- Mock LSP client
    lsp_client = {
      client_id = 1,
      request = spy.new(function() end),
      notify = spy.new(function() end),
    }
  end)

  describe('setup', function()
    it('does nothing when config is disabled', function()
      ghost_text.setup(lsp_client, { enabled = false })

      assert.is_nil(ghost_text.lsp_client)
      assert.is_nil(ghost_text.enabled)
      assert.spy(mock_vim.api.nvim_create_namespace).was_not_called()
    end)

    it('sets up the module with default configuration', function()
      ghost_text.setup(lsp_client, { enabled = true })

      assert.equals(lsp_client, ghost_text.lsp_client)
      assert.is_true(ghost_text.enabled)
      assert.spy(mock_vim.api.nvim_create_namespace).was_called_with('gitlab.GhostText')
      assert.spy(mock_vim.api.nvim_set_hl).was_called(2)
      assert
        .spy(mock_vim.api.nvim_create_augroup)
        .was_called_with('GitLabGhostText', { clear = true })
      assert.spy(mock_vim.api.nvim_create_autocmd).was_called(4)
    end)

    it('sets up custom keymaps when configured', function()
      ghost_text.setup(lsp_client, {
        enabled = true,
        toggle_enabled = '<C-g>t',
        accept_suggestion = '<C-g>y',
        clear_suggestions = '<C-g>c',
      })

      -- Three keymaps should be set
      assert.spy(mock_vim.keymap.set).was_called(3)
    end)
  end)

  describe('update_ghost_text', function()
    before_each(function()
      ghost_text.setup(lsp_client, { enabled = true })
    end)

    it('should return early when not enabled', function()
      ghost_text.enabled = false
      assert.is_nil(ghost_text.update_ghost_text(1))
      assert.spy(mock_vim.lsp.get_client_by_id).was_not_called()
    end)

    it('should return early when no client is found', function()
      ghost_text.lsp_client = nil

      assert.is_nil(ghost_text.update_ghost_text(1))
      assert.spy(mock_vim.lsp.get_client_by_id).was_not_called()
    end)

    it('should display_suggestion', function()
      local display_suggestion = spy.on(ghost_text, 'display_suggestion')

      lsp_client.request = spy.new(function(_, _, fn)
        fn(nil, { items = { { insertText = 'the suggestion' } } })
      end)

      ghost_text.update_ghost_text(ghost_text.edit_counter)
      assert.spy(display_suggestion).was_called_with({ { insertText = 'the suggestion' } })
    end)
  end)
end)
