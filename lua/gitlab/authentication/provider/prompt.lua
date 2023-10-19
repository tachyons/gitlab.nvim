local notifier = require('gitlab.notifier')

-- Lua module: gitlab.authentication.provider.prompt
local M = {}

M.prototype = {
  resolve = function(self, opts)
    if not self:url_set(opts) then
      return
    end

    if not self:token_set(opts) then
      return
    end

    return self
  end,
  token_set = function(self, opts)
    return self.token(opts) ~= nil
  end,
  url_set = function(self, opts)
    return self.url(opts) ~= nil
  end,
}

local function notify_input_error(err)
  local err_msg = tostring(err)

  if err_msg:match('Keyboard interrupt') then
    notifier.notify('User cancelled configuration request (with CTRL-C)', vim.log.levels.ERROR)
  else
    notifier.notify(
      'Unexpected error when waiting on user input: ' .. err_msg,
      vim.log.levels.ERROR
    )
  end
end

function M.new(options)
  local _token
  local _url

  local env = {
    token = function(opts)
      opts = opts or {}
      vim.validate({
        ['opts.force'] = { opts.force, 'boolean', true },
        ['opts.prompt_user'] = { opts.prompt_user, 'boolean', true },
      })

      if opts.prompt_user and not _token or opts.force then
        local ok, err = pcall(function()
          _token = vim.api.nvim_call_function('inputsecret', {
            'Enter your GitLab personal access token: ',
          })
        end)
        -- Clear prompt from screen before adding further messages.
        vim.cmd.redraw()

        if not ok then
          notify_input_error(err)
        end
      end

      return _token
    end,
    url = function(opts)
      opts = opts or {}
      vim.validate({
        ['opts.force'] = { opts.force, 'boolean', true },
        ['opts.prompt_user'] = { opts.prompt_user, 'boolean', true },
      })
      if opts.prompt_user and not _url or opts.force then
        local ok, err = pcall(function()
          -- input({prompt}, {text}) - See also `:help input()`.
          _url = vim.api.nvim_call_function('input', {
            'Enter GitLab URL: ',
            options.gitlab_url or 'https://gitlab.com',
          })
        end)
        -- Clear prompt from screen before adding further messages.
        vim.cmd.redraw()

        if not ok then
          notify_input_error(err)
        end
      end

      return _url
    end,
  }
  setmetatable(env, {
    __index = M.prototype,
  })

  return env
end

return M
