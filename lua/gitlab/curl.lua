local jobs = require('gitlab.lib.jobs')

-- Lua module: gitlab.curl
local M = {}

function M.available()
  return vim.fn.exepath('curl') ~= ''
end

function M.request(endpoint, req)
  req = req or {}
  req.headers = req.headers or {}
  req.headers = vim.tbl_extend('keep', req.headers, {
    ['Content-Type'] = 'application/json',
  })

  local auth = require('gitlab.authentication').default_resolver():resolve()
  req.headers = vim.tbl_extend('force', req.headers, {
    Accept = 'application/json',
    Authorization = 'Bearer ' .. auth.token(),
  })

  local cmd = { 'curl', endpoint }
  for header, value in pairs(req.headers) do
    table.insert(cmd, '-H')
    table.insert(cmd, string.format('%s: %s', header, value))
  end

  if req.body then
    table.insert(cmd, '-d')
    table.insert(cmd, vim.fn.json_encode(req.body))
  end

  local job, err = jobs.start_wait(cmd, {})
  if err then
    return nil, err
  end

  local ok, decoded = pcall(function()
    return vim.fn.json_decode(job.stdout)
  end)
  if ok then
    return decoded
  end

  return nil, 'Unable to decode API response'
end

return M
