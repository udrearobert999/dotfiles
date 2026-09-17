-- lua/robert/plugins/lsp.lua

return {
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      {
        'j-hui/fidget.nvim',
        opts = {
          progress = { display = { done_icon = '✓', done_ttl = 1 } },
          notification = { window = { winblend = 0 } },
        },
      },

      -- Allows extra capabilities provided by blink.cmp
      'saghen/blink.cmp',
    },
    config = function()
      -- This function gets run when an LSP attaches to a particular buffer.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('robert-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Rename the variable under your cursor.
          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

          -- Goto Declaration
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- Highlight references of the word under your cursor
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method('textDocument/documentHighlight', event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('robert-lsp-highlight', { clear = false })

            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('robert-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'robert-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- Toggle inlay hints if supported
          if client and client:supports_method('textDocument/inlayHint', event.buf) then
            map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- Capabilities from blink.cmp
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- Ensure encoding is consistent
      capabilities.general = capabilities.general or {}
      capabilities.general.positionEncodings = { 'utf-16' }

      -- Enable the following language servers
      local servers = {
        -- clangd = {},
        -- gopls = {},
        basedpyright = {
          handlers = {
            ['textDocument/publishDiagnostics'] = function() end,
          },
          settings = {
            basedpyright = {
              analysis = {
                useLibraryCodeForTypes = true,
              },
            },
          },
        },
        ruff = {},
        rust_analyzer = {
          settings = {
            ['rust-analyzer'] = {
              check = { command = 'clippy' },
            },
          },
        },
        ts_ls = {},
        eslint = {
          settings = {
            workingDirectories = { mode = 'auto' },
          },
        },
        starpls = {
          -- run the starpls process from the resolved workspace root, so its
          -- `bazel info`/`bazel query` calls succeed regardless of where
          -- nvim itself was launched from
          cmd = function(dispatchers, config) return vim.lsp.rpc.start({ 'starpls' }, dispatchers, { cwd = config.root_dir }) end,
        },
      }

      -- Ensure the servers and tools above are installed (mason package
      -- names, which don't always match the lspconfig server names above)
      local ensure_installed = {
        'lua-language-server',
        'stylua',
        'basedpyright',
        'ruff',
        'rust-analyzer',
        'typescript-language-server',
        'eslint-lsp',
        'starpls',
        'buildifier',
        'prettierd',
      }

      require('mason-tool-installer').setup {
        ensure_installed = ensure_installed,
      }

      -- Configure & enable all servers in the table
      for name, server in pairs(servers) do
        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
        vim.lsp.config(name, server)
        vim.lsp.enable(name)
      end

      -- Special Lua Config (Neovim config editing)
      vim.lsp.config('lua_ls', {
        on_init = function(client)
          if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
          end

          client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
              version = 'LuaJIT',
              path = { 'lua/?.lua', 'lua/?/init.lua' },
            },
            workspace = {
              checkThirdParty = false,
              -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
              library = vim.api.nvim_get_runtime_file('', true),
            },
          })
        end,
        capabilities = capabilities,
        settings = {
          Lua = {},
        },
      })
      vim.lsp.enable 'lua_ls'
    end,
  },
}
