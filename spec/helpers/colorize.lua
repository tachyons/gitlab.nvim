local is_headless = require('plenary.nvim_meta').is_headless

local ansi_colors = {
  reset_color = '\27[0m',
  red = '\27[31m',
  gray = '\27[37m',
}

local M = {
  reset_color = function(str)
    return ansi_colors.reset_color .. str
  end,
}
for color, code in pairs(ansi_colors) do
  if color ~= 'none' then
    M[color] = function(str)
      if is_headless then
        return code .. str .. ansi_colors.reset_color
      else
        return str
      end
    end
  end
end

return M
