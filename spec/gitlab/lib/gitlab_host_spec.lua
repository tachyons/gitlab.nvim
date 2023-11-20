describe('gitlab.lib.gitlab_host', function()
  local gitlab_host = require('gitlab.lib.gitlab_host')

  describe('parse', function()
    local tests = {
      { 'https://gitlab.com', { protocol = 'https', hostname = 'gitlab.com' } },
      { 'https://gitlab.com/', { protocol = 'https', hostname = 'gitlab.com' } },
      { 'http://gitlab.example.com', { protocol = 'http', hostname = 'gitlab.example.com' } },
      { 'http://gitlab.example.com/', { protocol = 'http', hostname = 'gitlab.example.com' } },
      { 'http://example.com/gitlab', { protocol = 'http', hostname = 'example.com' } },
      { 'http://example.com/gitlab/', { protocol = 'http', hostname = 'example.com' } },
    }
    for _, test in ipairs(tests) do
      local url, expected = test[1], test[2]
      it(url, function()
        assert.has.same(expected, gitlab_host.parse_http_url(url))
      end)
    end
  end)
end)
