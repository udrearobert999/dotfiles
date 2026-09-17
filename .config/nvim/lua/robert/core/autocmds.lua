-- lua/robert/core/autocmds.lua

-- Enable relative number in NORMAL / Disable them in INSERT
local relnum_group = vim.api.nvim_create_augroup('robert-relative-number', { clear = true })
vim.api.nvim_create_autocmd('InsertEnter', {
  desc = 'Disable relative numbers in insert mode',
  group = relnum_group,
  callback = function() vim.opt.relativenumber = false end,
})

vim.api.nvim_create_autocmd('InsertLeave', {
  desc = 'Enable relative numbers in normal mode',
  group = relnum_group,
  callback = function() vim.opt.relativenumber = true end,
})

-- Highlight when yanking
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('robert-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'oil_preview',
  desc = 'Accept oil confirmation dialog with Enter',
  group = vim.api.nvim_create_augroup('robert-oil-confirm-enter', { clear = true }),
  callback = function(args) vim.keymap.set('n', '<CR>', function() vim.api.nvim_input 'y' end, { buffer = args.buf, nowait = true }) end,
})

local focus_group = vim.api.nvim_create_augroup('robert-restore-focus', { clear = true })
local win_before_focus_lost

vim.api.nvim_create_autocmd('FocusLost', {
  desc = 'Remember the focused window before losing terminal focus',
  group = focus_group,
  callback = function() win_before_focus_lost = vim.api.nvim_get_current_win() end,
})

vim.api.nvim_create_autocmd('FocusGained', {
  desc = 'Restore focus to the window that had it before losing terminal focus',
  group = focus_group,
  callback = function()
    if win_before_focus_lost and vim.api.nvim_win_is_valid(win_before_focus_lost) then
      vim.api.nvim_set_current_win(win_before_focus_lost)
      if vim.fn.mode() == 't' then vim.cmd.stopinsert() end
    end
  end,
})
