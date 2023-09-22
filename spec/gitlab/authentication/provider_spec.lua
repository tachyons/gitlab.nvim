describe('gitlab.authentication.provider', function()
  local auth_provider = require('gitlab.authentication.provider')

  describe('env', function()
    local previous = {}
    before_each(function()
      previous.GITLAB_TOKEN = vim.env.GITLAB_TOKEN
      previous.GITLAB_VIM_URL = vim.env.GITLAB_VIM_URL
    end)

    after_each(function()
      vim.env.GITLAB_TOKEN = previous.GITLAB_TOKEN
      vim.env.GITLAB_VIM_URL = previous.GITLAB_VIM_URL
      previous = {}
    end)

    it('requires valid arguments', function()
      -- given
      vim.env.GITLAB_TOKEN = 'value_from_gitlab_token_var'
      vim.env.GITLAB_VIM_URL = 'value_from_gitlab_vim_url_var'

      -- then
      local actual = pcall(function()
        auth_provider.env(nil, nil)
      end)
      assert.are.same(false, actual)
    end)

    it('returns expected values if custom names are provided', function()
      -- given
      vim.env.GITLAB_TOKEN = 'incorrect'
      vim.env.GITLAB_VIM_URL = 'incorrect'
      vim.env.ONE = 'expected url'
      vim.env.TWO = 'expected token'

      -- when
      local provider = auth_provider.env(
        { gitlab_url = 'ONE', token = 'TWO' },
        { gitlab_url = 'https://gitlab.com' }
      )

      -- then
      assert.are.same(vim.env.TWO, provider:token())
      assert.are.same(vim.env.ONE, provider:url())
    end)

    it('returns https://gitlab.com when GITLAB_VIM_URL is unset.', function()
      -- given
      vim.env.GITLAB_TOKEN = nil
      vim.env.GITLAB_VIM_URL = nil

      -- when
      local provider = auth_provider.env(
        { gitlab_url = 'GITLAB_VIM_URL', token = 'GITLAB_TOKEN' },
        { gitlab_url = 'https://gitlab.com' }
      )

      -- then
      assert.are.same('https://gitlab.com', provider:url())
      assert.are.same(nil, provider:token())
    end)

    it('returns https://gitlab.example.org when GITLAB_VIM_URL is unset.', function()
      -- given
      vim.env.GITLAB_TOKEN = nil
      vim.env.GITLAB_VIM_URL = nil

      -- when
      local provider = auth_provider.env(
        { gitlab_url = 'GITLAB_VIM_URL', token = 'GITLAB_TOKEN' },
        { gitlab_url = 'https://gitlab.example.org' }
      )

      -- then
      assert.are.same('https://gitlab.example.org', provider:url())
    end)
  end)

  describe('prompt', function()
    local match = require('luassert.match')
    local stub = require('luassert.stub')

    local snapshot
    before_each(function()
      snapshot = assert:snapshot()
      stub(vim.api, 'nvim_call_function')
    end)

    after_each(function()
      snapshot:revert()
    end)

    it('resolves token', function()
      vim.api.nvim_call_function
        .on_call_with('inputsecret', match._)
        .returns('glpat-expected_token')

      local provider = auth_provider.prompt('https://gitlab.com')

      assert.are.same('glpat-expected_token', provider.token({ prompt_user = true, force = true }))
    end)

    it('resolves url', function()
      vim.api.nvim_call_function
        .on_call_with('input', match._)
        .returns('https://gitlab.example.org')

      local provider = auth_provider.prompt('https://gitlab.com')

      assert.are.same(
        'https://gitlab.example.org',
        provider.url({ prompt_user = true, force = true })
      )
    end)

    it('resolves GitLab instance url and token', function()
      vim.api.nvim_call_function
        .on_call_with('input', match._)
        .returns('https://gitlab.example.org')
      vim.api.nvim_call_function
        .on_call_with('inputsecret', match._)
        .returns('glpat-expected_token')

      local provider = auth_provider.prompt('https://gitlab.com')
      provider:resolve({ prompt_user = true, force = true })

      assert.stub(vim.api.nvim_call_function).was.called(2)
      assert.stub(vim.api.nvim_call_function).was.called_with('input', match._)
      assert.stub(vim.api.nvim_call_function).was.called_with('inputsecret', match._)
      assert.are.same('https://gitlab.example.org', provider.url())
      assert.are.same('glpat-expected_token', provider.token())
    end)
  end)
end)
