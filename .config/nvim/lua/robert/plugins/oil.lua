-- lua/robert/plugins/oil.lua

-- branch/dirty state is scoped to a git root, not a directory, so cache it
-- per root: navigating between subdirectories of the same repo in oil would
-- otherwise re-run a full `git status` (expensive on a monorepo) on every
-- single move.
local git_info_cache = {}

local function update_git_info(bufnr, root, force)
  if not force then
    local cached = git_info_cache[root]
    if cached ~= nil then
      vim.b[bufnr].gitsigns_head = cached
      return
    end
  end

  vim.system(
    { 'git', '-C', root, 'branch', '--show-current' },
    { text = true },
    vim.schedule_wrap(function(branch)
      if branch.code ~= 0 then
        git_info_cache[root] = false
        if vim.api.nvim_buf_is_valid(bufnr) then vim.b[bufnr].gitsigns_head = false end
        return
      end

      vim.system(
        { 'git', '-C', root, 'status', '--porcelain' },
        { text = true },
        vim.schedule_wrap(function(status)
          local dirty = status.code == 0 and status.stdout ~= ''
          local name = vim.trim(branch.stdout)
          local head = dirty and (name .. '*') or name

          git_info_cache[root] = head
          if vim.api.nvim_buf_is_valid(bufnr) then
            vim.b[bufnr].gitsigns_head = head
            vim.cmd.redrawstatus()
          end
        end)
      )
    end)
  )
end

return {
  {
    'stevearc/oil.nvim',
    lazy = false,
    keys = {
      { '-', '<CMD>Oil<CR>', desc = 'Open parent directory (Oil)' },
    },
    opts = {
      default_file_explorer = true,
      delete_to_trash = true,
      view_options = {
        show_hidden = true,
      },
      keymaps = {
        ['<C-h>'] = false,
        ['<C-l>'] = false,
        ['<C-x>'] = { 'actions.select', opts = { horizontal = true } },
        ['<C-g>'] = {
          desc = 'Refresh Oil and git info',
          callback = function()
            require('oil.actions').refresh.callback()
            local root = vim.fn.FindRootDirectory()
            if root ~= '' then update_git_info(vim.api.nvim_get_current_buf(), root, true) end
          end,
        },
      },
    },
    config = function(_, opts)
      require('oil').setup(opts)

      vim.api.nvim_create_autocmd('BufEnter', {
        group = vim.api.nvim_create_augroup('robert-oil-git-branch', {}),
        pattern = 'oil://*',
        callback = function(args)
          local bufnr = args.buf
          local root = vim.fn.FindRootDirectory()
          if root == '' then
            vim.b[bufnr].gitsigns_head = false
            return
          end

          update_git_info(bufnr, root, false)
        end,
      })
    end,
  },
}
