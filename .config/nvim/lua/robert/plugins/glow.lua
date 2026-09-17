-- lua/robert/plugins/glow.lua

return {
  {
    'ellisonleao/glow.nvim',
    ft = 'markdown',
    cmd = 'Glow',
    keys = {
      { '<leader>mp', '<cmd>Glow<CR>', ft = 'markdown', desc = '[M]arkdown [P]review (Glow)' },
    },
    opts = {
      border = 'rounded',
    },
  },
}
