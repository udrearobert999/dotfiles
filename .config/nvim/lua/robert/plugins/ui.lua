-- lua/robert/plugins/ui.lua

return {
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 0,
      icons = { mappings = vim.g.have_nerd_font },
      win = { border = 'rounded' },
      spec = {
        { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },
  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    config = function()
      require('gruvbox').setup { contrast = 'hard' }
      vim.o.background = 'light'
      vim.cmd.colorscheme 'gruvbox'
      vim.o.winborder = 'rounded'
    end,
  },
  {
    'nvim-mini/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()
    end,
  },

  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons', 'ellisonleao/gruvbox.nvim' },
    opts = {
      options = {
        theme = 'gruvbox',
        icons_enabled = vim.g.have_nerd_font,
        section_separators = { left = '', right = '' },
        component_separators = '',
      },
      sections = {
        lualine_c = {
          {
            'filename',
            path = 1, -- relative to cwd
            -- Plugin buffers (fugitive://, diffview://, ...) have URI names; show
            -- them as "scheme: <relative path>" with long hashes shortened.
            fmt = function(name)
              local scheme, rest = vim.api.nvim_buf_get_name(0):match '^(%w+)://(.*)$'
              if not scheme then return name end
              rest = vim.fn.fnamemodify(rest, ':~:.'):gsub('%.git//', ''):gsub('(%x%x%x%x%x%x%x%x%x%x)%x+', '%1')
              return ('%s: %s%s'):format(scheme, rest, vim.bo.modifiable and '' or ' [-]')
            end,
          },
        },
      },
      extensions = {
        {
          filetypes = { 'oil' },
          sections = {
            lualine_a = { 'mode' },
            lualine_b = { 'branch' },
            lualine_c = {
              function() return vim.fn.fnamemodify(require('oil').get_current_dir() or '', ':~') end,
            },
          },
        },
      },
    },
  },

  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },
}
