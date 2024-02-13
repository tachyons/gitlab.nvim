local mock = require('luassert.mock')
local config = require('gitlab.config')

describe('gitlab.resource_helper', function()
  local resource_helper = require('gitlab.resource_helper')
  local config_mock

  before_each(function()
    config_mock = mock(config, true)
    config_mock.current.returns({ gitlab_url = 'https://gitlab.example.com' })
  end)

  describe('resource_url_to_api_url', function()
    it('returns an error string for an invalid resource type', function()
      local result, err = resource_helper.resource_url_to_api_url(
        'https://gitlab.example.com/gitlab-org/gitlab/-/invalid_resource_type/1'
      )

      assert.equal(nil, result)
      assert.not_equal(nil, err)
    end)

    it('returns an error string for an invalid url', function()
      local result, err = resource_helper.resource_url_to_api_url('https://example.com/')

      assert.equal(nil, result)
      assert.not_equal(nil, err)
    end)

    it('matches an issue url', function()
      local result, err = resource_helper.resource_url_to_api_url(
        'https://gitlab.example.com/gitlab-org/gitlab/-/issues/1'
      )

      assert.equal(nil, err)
      assert.equal(
        'https://gitlab.example.com/api/v4/projects/gitlab-org%2Fgitlab/issues/1',
        result
      )
    end)

    it('matches a merge request url', function()
      local result, err = resource_helper.resource_url_to_api_url(
        'https://gitlab.example.com/gitlab-org/gitlab/-/merge_requests/1'
      )

      assert.equal(nil, err)
      assert.equal(
        'https://gitlab.example.com/api/v4/projects/gitlab-org%2Fgitlab/merge_requests/1',
        result
      )
    end)

    it('matches an epic url', function()
      local result, err = resource_helper.resource_url_to_api_url(
        'https://gitlab.example.com/groups/gitlab-org/a-subgroup/-/epics/1'
      )

      assert.equal(nil, err)
      assert.equal(
        'https://gitlab.example.com/api/v4/groups/gitlab-org%2Fa-subgroup/epics/1',
        result
      )
    end)

    it('works when gitlab_url includes a relative url and ends in slash', function()
      config_mock.current.returns({ gitlab_url = 'https://gitlab.example.com/my/relative-url/' })

      local result, err = resource_helper.resource_url_to_api_url(
        'https://gitlab.example.com/my/relative-url/groups/gitlab-org/a-subgroup/-/epics/1'
      )

      assert.equal(nil, err)
      assert.equal(
        'https://gitlab.example.com/my/relative-url/api/v4/groups/gitlab-org%2Fa-subgroup/epics/1',
        result
      )
    end)
  end)
end)
