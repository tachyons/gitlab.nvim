local mock = require('luassert.mock')
local glab = require('gitlab.glab')
local curl = require('gitlab.curl')
local rest = require('gitlab.api.rest')
local config = require('gitlab.config')

describe('gitlab.api.rest', function()
  local curl_mock
  local glab_mock

  before_each(function()
    curl_mock = mock(curl, true)
    glab_mock = mock(glab, true)
    curl_mock.available.returns(false)
    glab_mock.available.returns(false)

    curl_mock.request.returns('curl.request result')
    glab_mock.api.returns('glab.api result')
  end)

  after_each(function()
    mock.revert(curl_mock)
    mock.revert(glab_mock)
  end)

  describe('request', function()
    it('calls curl.request when available', function()
      curl_mock.available.returns(true)
      local result = rest.request('http://example.com/foo_bar', { method = 'GET' })
      assert.equal('curl.request result', result)

      mock.revert(curl_mock)
    end)

    it('calls glab.api when available', function()
      glab_mock.available.returns(true)
      local result = rest.request('http://example.com/foo_bar', { method = 'GET' })
      assert.equal('glab.api result', result)

      mock.revert(glab_mock)
    end)
  end)

  describe('api_v4_url', function()
    it('generates an API 4 URL from a path', function()
      local config_mock = mock(config, true)
      config_mock.current.returns({ gitlab_url = 'https://gitlab.example.com' })

      local result = rest.api_v4_url('projects/123')
      assert.equal('https://gitlab.example.com/api/v4/projects/123', result)

      -- It removes the extra leading slash
      result = rest.api_v4_url('/projects/123')
      assert.equal('https://gitlab.example.com/api/v4/projects/123', result)

      mock.revert(config_mock)
    end)

    it('handles gitlab_url with relative url ending in slash', function()
      local config_mock = mock(config, true)
      config_mock.current.returns({ gitlab_url = 'https://gitlab.example.com/my/relative-url/' })

      local result = rest.api_v4_url('projects/123')
      assert.equal('https://gitlab.example.com/my/relative-url/api/v4/projects/123', result)

      -- It removes the extra leading slash
      result = rest.api_v4_url('/projects/123')
      assert.equal('https://gitlab.example.com/my/relative-url/api/v4/projects/123', result)

      mock.revert(config_mock)
    end)
  end)
end)
