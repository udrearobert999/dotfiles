-- lua/robert/plugins/fzf.lua

local function fzf(picker, opts)
  return function() require('fzf-lua')[picker](opts) end
end

-- <C-hjkl> leave the picker for the neighbouring split/tmux pane. The picker
-- is hidden rather than closed, so <leader>sr (resume) restores it instantly.
local function nav_mappings(bufnr)
  for lhs, move in pairs(require 'robert.util.nav') do
    vim.keymap.set('t', lhs, function()
      require('fzf-lua').hide()
      move()
    end, { buffer = bufnr, desc = 'Leave picker (tmux-aware)' })
  end
end

return {
  {
    'ibhagwan/fzf-lua',
    dependencies = { { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font } },
    cmd = 'FzfLua',
    opts = {
      'hide',
      defaults = { formatter = 'path.filename_first' },
      keymap = {
        builtin = {
          true,
          ['<M-p>'] = 'toggle-preview',
          ['<C-d>'] = 'preview-half-page-down',
          ['<C-u>'] = 'preview-half-page-up',
        },
      },
    },
    config = function(_, opts)
      local fzf_lua = require 'fzf-lua'
      fzf_lua.setup(opts)
      fzf_lua.register_ui_select()
    end,

    keys = {
      { '<leader>gf', fzf 'git_files', desc = '[G]it [F]iles' },
      {
        '<leader>gg',
        fzf('live_grep', { cmd = 'git --no-pager grep --line-number --column --color=always', prompt = 'Git Grep> ' }),
        desc = '[G]it [G]rep',
      },

      { '<leader>sf', fzf 'files', desc = '[S]earch [F]iles' },
      { '<leader>sw', fzf 'grep_cword', desc = '[S]earch current [W]ord' },
      { '<leader>sw', fzf 'grep_visual', desc = '[S]earch current [W]ord', mode = 'v' },
      { '<leader>sg', fzf 'live_grep', desc = '[S]earch by [G]rep' },
      { '<leader>sk', fzf 'keymaps', desc = '[S]earch [K]eymaps' },
      { '<leader>sh', fzf 'helptags', desc = '[S]earch [H]elp' },
      { '<leader>ss', fzf 'builtin', desc = '[S]earch [S]elect picker' },
      { '<leader>sd', fzf 'diagnostics_workspace', desc = '[S]earch [D]iagnostics' },
      { '<leader>sr', fzf 'resume', desc = '[S]earch [R]esume' },
      { '<leader>s.', fzf 'oldfiles', desc = '[S]earch Recent Files ("." for repeat)' },
      { '<leader>sc', fzf 'commands', desc = '[S]earch [C]ommands' },
      { '<leader><leader>', fzf 'buffers', desc = '[ ] Find existing buffers' },
      { '<leader>/', fzf 'blines', desc = '[/] Fuzzily search in current buffer' },
      { '<leader>s/', fzf 'lines', desc = '[S]earch [/] in Open Files' },
      { '<leader>sn', function() require('fzf-lua').files { cwd = vim.fn.stdpath 'config' } end, desc = '[S]earch [N]eovim files' },
    },

    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'fzf',
        group = vim.api.nvim_create_augroup('robert-fzf-nav', { clear = true }),
        callback = function(event) nav_mappings(event.buf) end,
      })

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('robert-fzf-lsp-attach', { clear = true }),
        callback = function(event)
          local function map(lhs, picker, desc) vim.keymap.set('n', lhs, fzf(picker), { buffer = event.buf, desc = desc }) end

          map('grr', 'lsp_references', '[G]oto [R]eferences')
          map('gri', 'lsp_implementations', '[G]oto [I]mplementation')
          map('grd', 'lsp_definitions', '[G]oto [D]efinition')
          map('grt', 'lsp_typedefs', '[G]oto [T]ype Definition')
          map('gO', 'lsp_document_symbols', 'Open Document Symbols')
          map('gW', 'lsp_live_workspace_symbols', 'Open Workspace Symbols')
        end,
      })
    end,
  },
}
