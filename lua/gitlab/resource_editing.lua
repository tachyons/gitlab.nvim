local resource_helper = require('gitlab.resource_helper')
local rest = require('gitlab.api.rest')
local config = require('gitlab.config').current()
local notifier = require('gitlab.notifier')

local function update_gitlab_issuable(buffer, api_url)
  local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
  local description = table.concat(lines, '\n')
  rest.request(api_url, { method = 'PUT', params = { description = description } })

  vim.cmd('set nomodified')
end

local function open_gitlab_issuable(api_url)
  local issuable, err = rest.request(api_url, { method = 'GET' })

  if err then
    notifier.notify(err, vim.log.levels.ERROR)
    return
  end

  local buffer = vim.api.nvim_get_current_buf()

  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, vim.split(issuable.description or '', '\n'))

  vim.bo.filetype = 'markdown'

  vim.api.nvim_set_current_buf(buffer)
  vim.api.nvim_create_autocmd('BufWriteCmd', {
    buffer = buffer,
    callback = function()
      update_gitlab_issuable(buffer, api_url)
    end,
  })
end

local function open_gitlab_resource(url)
  local api_url, err = resource_helper.resource_url_to_api_url(url)
  if err then
    notifier.notify(err, vim.log.levels.ERROR)
    return
  end

  open_gitlab_issuable(api_url)
end

if config.resource_editing.enabled then
  vim.api.nvim_create_autocmd('BufReadCmd', {
    pattern = vim.fn.join({ config.gitlab_url, '*' }, '/'),
    callback = function(args)
      -- Clear netrw as it will interfere
      vim.api.nvim_clear_autocmds({
        group = 'Network',
        event = { 'BufReadCmd' },
        pattern = { 'https://*' },
      })

      open_gitlab_resource(args.file)
    end,
  })
end
