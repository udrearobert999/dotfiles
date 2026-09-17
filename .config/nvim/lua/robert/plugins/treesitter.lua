-- lua/robert/plugins/treesitter.lua

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    lazy = false,
    config = function()
      require('nvim-treesitter').install {
        'javascript',
        'typescript',
        'tsx',
        'json',
        'yaml',
        'html',
        'css',
        'rust',
        'go',
        'python',
        'starlark',
        'lua',
      }

      vim.api.nvim_create_autocmd('FileType', {
        pattern = {
          'javascript',
          'typescript',
          'typescriptreact',
          'json',
          'yaml',
          'html',
          'css',
          'rust',
          'go',
          'python',
          'bzl',
          'lua',
        },
        callback = function()
          vim.treesitter.start()
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}
