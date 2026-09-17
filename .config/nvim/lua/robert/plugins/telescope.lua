-- lua/robert/plugins/telescope.lua

-- Telescope closes its picker on BufLeave of the prompt buffer (hardcoded in
-- pickers.lua, no config toggle). Clear that specific autocmd group before
-- navigating away so the picker stays open, unfocused, until returned to.
local function keep_open_on_leave(move)
  return function(prompt_bufnr)
    pcall(vim.api.nvim_clear_autocmds, { group = 'PickerInsert', buffer = prompt_bufnr })
    move()
  end
end

return {
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function() return vim.fn.executable 'make' == 1 end,
      },
      'nvim-telescope/telescope-ui-select.nvim',
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },

    opts = function()
      local themes = require 'telescope.themes'
      local actions = require 'telescope.actions'
      local nav = {}
      for lhs, move in pairs(require 'robert.util.nav') do
        nav[lhs] = keep_open_on_leave(move)
      end

      return {
        defaults = {
          path_display = { 'shorten' },
          mappings = {
            i = vim.tbl_extend('force', nav, {
              ['<C-e>'] = actions.preview_scrolling_right,
            }),
            n = nav,
          },
        },
        extensions = {
          ['ui-select'] = themes.get_dropdown(),
        },
      }
    end,

    config = function(_, opts)
      local telescope = require 'telescope'
      telescope.setup(opts)
      pcall(telescope.load_extension, 'fzf')
      pcall(telescope.load_extension, 'ui-select')
    end,

    keys = {
      { '<leader>gf', function() require('telescope.builtin').git_files() end, desc = '[G]it [F]iles' },
      {
        '<leader>gg',
        function()
          require('telescope.builtin').live_grep {
            vimgrep_arguments = { 'git', '--no-pager', 'grep', '--line-number', '--column', '--color=never' },
            prompt_title = 'Git Grep',
          }
        end,
        desc = '[G]it [G]rep',
      },

      { '<leader>sf', function() require('telescope.builtin').find_files() end, desc = '[S]earch [F]iles' },
      { '<leader>sw', function() require('telescope.builtin').grep_string() end, desc = '[S]earch current [W]ord', mode = { 'n', 'v' } },
      { '<leader>sg', function() require('telescope.builtin').live_grep() end, desc = '[S]earch by [G]rep' },
      { '<leader>sk', function() require('telescope.builtin').keymaps() end, desc = '[S]earch [K]eymaps' },
      { '<leader>sh', function() require('telescope.builtin').help_tags() end, desc = '[S]earch [H]elp' },
      { '<leader>ss', function() require('telescope.builtin').builtin() end, desc = '[S]earch [S]elect Telescope' },
      { '<leader>sd', function() require('telescope.builtin').diagnostics() end, desc = '[S]earch [D]iagnostics' },
      { '<leader>sr', function() require('telescope.builtin').resume() end, desc = '[S]earch [R]esume' },
      { '<leader>s.', function() require('telescope.builtin').oldfiles() end, desc = '[S]earch Recent Files ("." for repeat)' },
      { '<leader>sc', function() require('telescope.builtin').commands() end, desc = '[S]earch [C]ommands' },
      { '<leader><leader>', function() require('telescope.builtin').buffers() end, desc = '[ ] Find existing buffers' },

      -- Special keys:
      {
        '<leader>/',
        function()
          local builtin = require 'telescope.builtin'
          local themes = require 'telescope.themes'
          builtin.current_buffer_fuzzy_find(themes.get_dropdown {
            winblend = 10,
            previewer = false,
          })
        end,
        desc = '[/] Fuzzily search in current buffer',
      },
      {
        '<leader>s/',
        function()
          require('telescope.builtin').live_grep {
            grep_open_files = true,
            prompt_title = 'Live Grep in Open Files',
          }
        end,
        desc = '[S]earch [/] in Open Files',
      },
      {
        '<leader>sn',
        function() require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' } end,
        desc = '[S]earch [N]eovim files',
      },
    },

    init = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('robert-telescope-lsp-attach', { clear = true }),
        callback = function(event)
          local builtin = require 'telescope.builtin'
          local buf = event.buf

          vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })
          vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })
          vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })
          vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
          vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })
          vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })
        end,
      })
    end,
  },
}
