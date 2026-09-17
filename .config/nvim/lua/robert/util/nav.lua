-- lua/robert/util/nav.lua

local ss = require 'smart-splits'

return {
  ['<C-h>'] = ss.move_cursor_left,
  ['<C-j>'] = ss.move_cursor_down,
  ['<C-k>'] = ss.move_cursor_up,
  ['<C-l>'] = ss.move_cursor_right,
}
