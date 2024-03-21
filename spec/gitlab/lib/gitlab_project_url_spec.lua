local gitlab_project_url = require('gitlab.lib.gitlab_project_url')

-- References:
--
-- 1. https://stackoverflow.com/questions/31801271/what-are-the-supported-git-url-formats
-- 2. https://github.com/linrongbin16/giturlparser.lua#patterns
describe('gitlab_project_url', function()
  describe('Local paths', function()
    local paths = {
      '../x/y.git',
      './x.git',
      '/a/b/c',
      'file:///repo.git',
      'file://user:passwd@host.xyz:port/path/to/the/repo.git',
      'file://~/home/to/the/repo.git',
      'x.git',
      '~/x/y/z.git',
    }

    for _, path in ipairs(paths) do
      describe(path, function()
        local actual = gitlab_project_url.parse(path)

        it('does not fudge an invalid project path', function()
          assert.is.equal(nil, actual.full_path)
        end)

        it('returns a git remote', function()
          assert.is.equal(path, actual.remote_uri)
        end)
      end)
    end
  end)

  describe('Protocols', function()
    local tests = {
      { input = 'http://host.xyz/group/repo.git', full_path = 'group/repo' },
      { input = 'https://git@127.0.0.1:12345/group/repo.git', full_path = 'group/repo' },
      {
        input = 'https://gitlab.com/gitlab-org/editor-extensions/gitlab.vim.git',
        full_path = 'gitlab-org/editor-extensions/gitlab.vim',
      },
      { input = 'https://gitlab.com/gitlab-org/gitlab.git', full_path = 'gitlab-org/gitlab' },
      { input = 'ssh://host.xyz:port/path/to/the/repo.git', full_path = 'path/to/the/repo' },
      {
        input = 'ssh://username:password@host.xyz:port/path/to/the/repo.git',
        full_path = 'path/to/the/repo',
      },
    }
    for _, test in ipairs(tests) do
      it(test.input, function()
        local actual = gitlab_project_url.parse(test.input)
        local expected = test.full_path
        assert.is.equal(expected, actual.full_path)
        assert.is.equal(test.input, actual.remote_uri)
      end)
    end
  end)

  describe('Schemeless protocols', function()
    local tests = {
      {
        input = 'git@gitlab.com:gitlab-org/editor-extensions/gitlab.vim.git',
        full_path = 'gitlab-org/editor-extensions/gitlab.vim',
      },
      { input = 'git@host.xyz:group/repo.git', full_path = 'group/repo' },
      { input = 'user:passwd@host.xyz:path/to/the/repo.git', full_path = 'path/to/the/repo' },
    }
    for _, test in ipairs(tests) do
      it(test.input, function()
        local actual = gitlab_project_url.parse(test.input)
        local expected = test.full_path
        assert.is.equal(expected, actual.full_path)
        assert.is.equal(test.input, actual.remote_uri)
      end)
    end
  end)
end)
