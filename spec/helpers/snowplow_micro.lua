local curl = require('plenary.curl')

local SNOWPLOW_MICRO_URL = vim.env.SNOWPLOW_MICRO_URL or 'http://127.0.0.1:9091'

local snowplow_micro_url = function(path)
  path = path or ''
  path = path:gsub('^/', '')
  if path == '' then
    return SNOWPLOW_MICRO_URL
  end

  return vim.fn.join({ SNOWPLOW_MICRO_URL, path }, '/')
end

local _snowplow_running = nil
return {
  available = function()
    if _snowplow_running == nil then
      local job = curl.get({
        callback = function(response)
          _snowplow_running = response.status == 200
        end,
        on_error = function(err)
          _snowplow_running = false
          error(err and err.message)
        end,
        url = snowplow_micro_url('/micro/good'),
      })
      local timeout_millis = 1000
      job:sync(timeout_millis)
    end

    return _snowplow_running
  end,
  good_events = function()
    local response = curl.get(snowplow_micro_url('/micro/good'))
    return vim.fn.json_decode(response.body)
  end,
  reset = function()
    curl.get(snowplow_micro_url('/micro/reset'))
  end,
  url = snowplow_micro_url,
}
