-- lua/robert/plugins/fugitive.lua

return {
  'tpope/vim-fugitive',
  config = function()
    local function toggle_fugitive_window(filetype, open)
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == filetype then
          vim.api.nvim_win_close(win, false)
          return
        end
      end
      open()
    end

    vim.keymap.set(
      'n',
      '<leader>gs',
      function() toggle_fugitive_window('fugitive', vim.cmd.Git) end,
      { desc = '[G]it [S]tatus (Fugitive)' }
    )
    vim.keymap.set(
      'n',
      '<leader>gb',
      function() toggle_fugitive_window('fugitiveblame', function() vim.cmd.Git 'blame' end) end,
      { desc = '[G]it [B]lame' }
    )

    local robert_fugitive_group = vim.api.nvim_create_augroup('robert-fugitive-group', {})

    local autocmd = vim.api.nvim_create_autocmd

    -- In the blame window, `d` shows a side-by-side diff of the blamed file
    -- before/after the commit under the cursor.
    autocmd('FileType', {
      group = robert_fugitive_group,
      pattern = 'fugitiveblame',
      callback = function(event)
        vim.keymap.set('n', 'd', function()
          local sha = vim.api.nvim_get_current_line():match '^%^?(%x+)'
          if not sha or sha:match '^0+$' then return vim.notify('Line not committed yet', vim.log.levels.WARN) end

          local blame_win = vim.api.nvim_get_current_win()
          local source_win
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if win ~= blame_win and vim.wo[win].scrollbind then source_win = win end
          end
          if not source_win then return end

          local file = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(source_win))
          local root = vim.fn.FugitiveWorkTree()
          local path = vim.fs.relpath(root, file)
          if not path then return end

          vim.api.nvim_win_close(blame_win, false)
          vim.api.nvim_set_current_win(source_win)
          vim.cmd.Gedit(sha .. ':' .. path)
          if vim.system({ 'git', '-C', root, 'cat-file', '-e', sha .. '^:' .. path }):wait().code == 0 then
            vim.cmd.Gvdiffsplit { sha .. '^', mods = { split = 'aboveleft' } }
          else
            vim.notify(path .. ' was added in ' .. sha:sub(1, 10), vim.log.levels.INFO)
          end
        end, { buffer = event.buf, nowait = true, desc = 'Diff file before/after this commit' })
      end,
    })

    autocmd('BufWinEnter', {
      group = robert_fugitive_group,
      pattern = '*',
      callback = function()
        if vim.bo.ft ~= 'fugitive' then return end

        local bufnr = vim.api.nvim_get_current_buf()
        local opts = { buffer = bufnr, remap = false }
        vim.keymap.set('n', '<leader>p', function() vim.cmd.Git 'push' end, opts)

        -- rebase always
        vim.keymap.set('n', '<leader>P', function() vim.cmd.Git { 'pull', '--rebase' } end, opts)

        -- NOTE: It allows me to easily set the branch i am pushing and any tracking
        -- needed if i did not set the branch up correctly
        vim.keymap.set('n', '<leader>t', ':Git push -u origin ', opts)
      end,
    })

    vim.keymap.set('n', 'gu', '<cmd>diffget //2<CR>')
    vim.keymap.set('n', 'gh', '<cmd>diffget //3<CR>')
  end,
}
