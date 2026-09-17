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
