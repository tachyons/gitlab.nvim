describe('gitlab.resource_helper', function()
  local resource_helper = require('gitlab.resource_helper')

  describe('resource_url_to_api_url', function()
    it('returns an error string for an invalid url', function()
      local result, err = resource_helper.resource_url_to_api_url(
        'https://gitlab.com/gitlab-org/gitlab/-/invalid_resource_type/1'
      )

      assert.equal(nil, result)
      assert.not_equal(nil, err)
    end)

    it('returns an error string for an invalid resource type', function()
      local result, err = resource_helper.resource_url_to_api_url('https://example.com')

      assert.equal(nil, result)
      assert.not_equal(nil, err)
    end)

    it('matches an issue url', function()
      local result, err =
        resource_helper.resource_url_to_api_url('https://gitlab.com/gitlab-org/gitlab/-/issues/1')

      assert.equal(nil, err)
      assert.equal('https://gitlab.com/api/v4/projects/gitlab-org%2Fgitlab/issues/1', result)
    end)

    it('matches a merge request url', function()
      local result = resource_helper.resource_url_to_api_url(
        'https://gitlab.com/gitlab-org/gitlab/-/merge_requests/1'
      )

      assert.equal(
        'https://gitlab.com/api/v4/projects/gitlab-org%2Fgitlab/merge_requests/1',
        result
      )
    end)

    it('matches an epic url', function()
      local result = resource_helper.resource_url_to_api_url(
        'https://gitlab.com/groups/gitlab-org/a-subgroup/-/epics/1'
      )

      assert.equal('https://gitlab.com/api/v4/groups/gitlab-org%2Fa-subgroup/epics/1', result)
    end)
  end)
end)
