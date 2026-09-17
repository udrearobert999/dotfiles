-- lua/robert/core/keymaps.lua

-- Map leader to space
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Clear highlights on search when pressing <Esc> in normal mode, or close any
-- stray floating windows (e.g. a glow preview that lost focus after a
-- terminal focus round-trip and can no longer be closed via its own keymap)
vim.keymap.set('n', '<Esc>', function()
  local closed_float = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative ~= '' then
      vim.api.nvim_win_close(win, false)
      closed_float = true
    end
  end
  if not closed_float then vim.cmd.nohlsearch() end
end)

-- Diagnostic list
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Custom
vim.keymap.set('n', '<leader>pv', vim.cmd.Oil)
vim.keymap.set('n', '<leader>oo', function()
  if vim.bo.filetype ~= 'oil' then
    vim.cmd.Oil()
  end
  vim.cmd.vsplit()
end, { desc = 'Open dual-pane Oil' })
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')
vim.keymap.set('x', '<leader>p', '"_dP')
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', 'J', 'mzJ`z')
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')
vim.keymap.set({ 'n', 'v' }, '<leader>d', '"_d')
vim.keymap.set('n', '[q', '<cmd>cprev<CR>zz')
vim.keymap.set('n', ']q', '<cmd>cnext<CR>zz')
vim.keymap.set('n', '<leader>\\', '<cmd>vsplit<CR>')
vim.keymap.set('n', '<leader>-', '<cmd>split<CR>')
vim.keymap.set('n', '<C-_>', function()
  if vim.w.zoom_layout then
    vim.cmd(vim.w.zoom_layout)
    vim.w.zoom_layout = nil
  else
    vim.w.zoom_layout = vim.fn.winrestcmd()
    vim.cmd.wincmd '_'
    vim.cmd.wincmd '|'
  end
end, { desc = 'Toggle maximize current split' })

vim.keymap.set('n', '<leader>u', function()
  vim.cmd.packadd 'nvim.undotree'
  vim.cmd.Undotree()
end, { desc = 'Toggle Undotree' })

local function current_abs_path()
  if vim.bo.filetype ~= 'oil' then return vim.fn.expand '%:p' end

  local oil = require 'oil'
  local dir = oil.get_current_dir()
  local entry = oil.get_cursor_entry()
  return entry and (dir .. entry.name) or dir
end

local copy_to_clipboard = require 'robert.util.clipboard'

vim.keymap.set('n', '<leader>ya', function() copy_to_clipboard(current_abs_path()) end, { desc = '[Y]ank [A]bsolute path' })

vim.keymap.set('n', '<leader>yf', function()
  if vim.bo.filetype ~= 'oil' and vim.bo.buftype ~= '' then
    vim.api.nvim_echo({ { 'No file open' } }, false, {})
    return
  end
  copy_to_clipboard(vim.fs.basename((current_abs_path():gsub('/$', ''))))
end, { desc = '[Y]ank [F]ilename' })

vim.keymap.set('n', '<leader>yr', function()
  local abs = current_abs_path()
  local root = (vim.fn.FindRootDirectory():gsub('/+', '/'))
  local path = (root ~= '') and abs:sub(#root + 2) or vim.fn.fnamemodify(abs, ':.')
  if path == '' then path = '.' end
  copy_to_clipboard(path)
end, { desc = '[Y]ank [R]epo-relative path' })
