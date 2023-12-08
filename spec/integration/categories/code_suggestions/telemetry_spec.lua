local conditions = require('spec.helpers.conditions')
local guard_describe = require('spec.helpers.guard_describe')
local typist = require('spec.helpers.typist')

guard_describe('gitlab.commands.code_suggestions', conditions.snowplow_micro_available, function()
  local code_suggestions_commands = require('gitlab.commands.code_suggestions')
  local mock = require('luassert.mock')
  local snowplow_micro = require('spec.helpers.snowplow_micro')
  local stub = require('luassert.stub')

  local snapshot
  local new_buf

  before_each(function()
    snapshot = assert:snapshot()

    new_buf = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_set_current_buf(new_buf)
    vim.opt.completeopt = { 'menu', 'menuone' }

    local status, err = pcall(function()
      require('gitlab').setup({
        language_server = {
          workspace_settings = {
            telemetry = {
              enabled = true,
              trackingUrl = snowplow_micro.url(),
            },
          },
        },
      })
    end)

    if not status then
      assert.same(nil, err, 'Expected no errors during setup.')
    end
  end)

  after_each(function()
    vim.opt.completeopt = {}
    vim.api.nvim_buf_delete(new_buf, { force = true })
    snapshot:revert()
  end)

  describe('with invalid credentials', function()
    it('does not set omnifunc', function()
      vim.api.nvim_put({
        '# Create a method that gives a name or says hello world.',
        'def ',
      }, 'l', true, false)

      -- when
      typist.under_insert_mode(function(press)
        -- Enter the insert_expand sub-mode.
        press.ctrl('x')

        -- Start omni completion.
        press.ctrl('o')
      end)

      -- then - ctrl-x ctrl-o returns an error since omnifunc is not set
      assert.are.same("E764: Option 'omnifunc' is not set", vim.v.errmsg)
    end)
  end)

  guard_describe(
    'with valid personal access token',
    conditions.token({ using = 'GITLAB_TOKEN', require_scopes = { 'api' } }),
    function()
      before_each(function()
        local status, err = pcall(function()
          local env_auth = mock(require('gitlab.authentication.provider.env'))
          stub(env_auth, 'resolve').returns(env_auth)
          stub(env_auth, 'token').returns(vim.env.GITLAB_TOKEN)
          stub(env_auth, 'token_set').returns(true)
          stub(env_auth, 'url').returns('https://gitlab.com')
          stub(env_auth, 'url_set').returns(true)
          local workspace = require('gitlab.lsp.workspace').new()
          code_suggestions_commands.create({
            group = 1,
            auth = env_auth,
            workspace = workspace,
          })

          -- Install code suggestions like a user would.
          vim.cmd.GitLabCodeSuggestionsInstallLanguageServer()
        end)

        if not status then
          assert.same(nil, err, 'Expected no errors during setup.')
        end
      end)

      it('opens the popup menu', function()
        vim.api.nvim_put({
          '# Create a method that gives a name or says hello world.',
        }, 'l', true, false)

        vim.cmd.GitLabCodeSuggestionsStart()

        vim.wait(3000, function()
          return #vim.lsp.get_active_clients() > 1
        end)

        -- when
        typist.under_insert_mode(function(press)
          -- Enter the insert_expand sub-mode.
          press.ctrl('x')

          -- Start omni completion.
          press.ctrl('o')

          -- Accept suggestion.
          press.ctrl('y')
        end)
        vim.wait(4000, function() end)

        -- then - we receive telemetry
        local events = snowplow_micro.good_events()
        assert.are.not_same({}, events, 'Expected at least one good event.')
      end)
    end
  )
end)
