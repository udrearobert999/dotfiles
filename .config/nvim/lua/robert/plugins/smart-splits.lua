-- lua/robert/plugins/smart-splits.lua

return {
  'mrjones2014/smart-splits.nvim',
  lazy = false,
  config = function()
    local ss = require 'smart-splits'
    ss.setup {}

    for lhs, rhs in pairs(require 'robert.util.nav') do
      vim.keymap.set('n', lhs, rhs, { desc = 'Move focus (tmux-aware)' })
    end
    vim.keymap.set('n', '<C-\\>', ss.move_cursor_previous, { desc = 'Move focus to previous (tmux-aware)' })

    vim.keymap.set('n', '<M-h>', ss.resize_left, { desc = 'Resize split/pane left' })
    vim.keymap.set('n', '<M-j>', ss.resize_down, { desc = 'Resize split/pane down' })
    vim.keymap.set('n', '<M-k>', ss.resize_up, { desc = 'Resize split/pane up' })
    vim.keymap.set('n', '<M-l>', ss.resize_right, { desc = 'Resize split/pane right' })
  end,
}
