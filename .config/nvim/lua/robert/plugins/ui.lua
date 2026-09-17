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
    'Mofiqul/dracula.nvim',
    priority = 1000,
    config = function()
      require('dracula').setup {
        italic_comment = false,
        transparent_bg = false,
        overrides = function(colors)
          return {
            FloatBorder = { fg = colors.comment },
          }
        end,
      }
      vim.cmd.colorscheme 'dracula'
      vim.o.winborder = 'rounded'
    end,
  },
  {
    'nvim-mini/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }
      statusline.section_location = function() return '%2l:%-2v' end

      statusline.section_git = function(args)
        if statusline.is_truncated(args.trunc_width) then return '' end

        local summary = vim.b.minigit_summary_string or vim.b.gitsigns_head
        if summary == false then return '' end
        if summary == nil then
          local ok, head = pcall(vim.fn.FugitiveHead)
          summary = (ok and head ~= '') and head or nil
        end
        if summary == nil then return '' end

        local use_icons = vim.g.have_nerd_font
        local icon = args.icon or (use_icons and '' or 'Git')
        return icon .. ' ' .. (summary == '' and '-' or summary)
      end
    end,
  },

  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },
}
