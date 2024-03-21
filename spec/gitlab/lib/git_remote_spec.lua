local git_remote = require('gitlab.lib.git_remote')
local jobs = require('gitlab.lib.jobs')
local stub = require('luassert.stub')

describe('gitlab.lib.git_remote', function()
  local snapshot

  before_each(function()
    snapshot = assert:snapshot()
  end)

  after_each(function()
    snapshot:revert()
  end)

  it('includes the origin remote', function()
    stub(jobs, 'start_wait').returns({
      exit_code = 0,
      stderr = '',
      stdout = vim.fn.join({
        'origin\tgit@gitlab.com:gitlab-org/editor-extensions/gitlab.vim.git (fetch)',
        'origin\tgit@gitlab.com:gitlab-org/editor-extensions/gitlab.vim.git (push)',
      }, '\n'),
    }, nil)

    local expected = {
      origin = 'git@gitlab.com:gitlab-org/editor-extensions/gitlab.vim.git',
    }

    assert.is.same(expected, git_remote.remotes())
  end)

  it('includes all remotes', function()
    stub(jobs, 'start_wait').returns({
      exit_code = 0,
      stderr = '',
      stdout = vim.fn.join({
        'community\tgit@gitlab.com:gitlab-community/gitlab-vscode-extension (fetch)',
        'community\tgit@gitlab.com:gitlab-community/gitlab-vscode-extension (push)',
        'gitlab-renovate-fork\tgit@gitlab.com:gitlab-renovate-forks/gitlab-vscode-extension.git (fetch)',
        'gitlab-renovate-fork\tgit@gitlab.com:gitlab-renovate-forks/gitlab-vscode-extension.git (push)',
        'origin\tgit@gitlab.com:gitlab-org/gitlab-vscode-extension (fetch)',
        'origin\tgit@gitlab.com:gitlab-org/gitlab-vscode-extension (push)',
      }, '\n'),
    }, nil)

    local expected = {
      community = 'git@gitlab.com:gitlab-community/gitlab-vscode-extension',
      origin = 'git@gitlab.com:gitlab-org/gitlab-vscode-extension',
      ['gitlab-renovate-fork'] = 'git@gitlab.com:gitlab-renovate-forks/gitlab-vscode-extension.git',
    }

    assert.is.same(expected, git_remote.remotes())
  end)
end)
