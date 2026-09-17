-- lua/robert/plugins/rooter.lua

return {
  'airblade/vim-rooter',
  lazy = false,
  init = function()
    vim.g.rooter_patterns = { '.git' }
    vim.g.rooter_cd_cmd = 'lcd'
    vim.g.rooter_change_directory_for_non_project_files = 'current'
    vim.g.rooter_silent_chdir = 1
  end,
}
