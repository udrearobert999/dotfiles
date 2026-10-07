-- lua/robert/plugins/bazel.lua

return {
  {
    url = 'git@git.corp.adobe.com:rudrea/telescope-bazel.nvim.git',
    branch = 'fzf-lua-support',
    dependencies = { 'ibhagwan/fzf-lua' },
    ft = 'bzl',
    keys = {
      {
        '<leader>bt',
        function() require('telescope_bazel.fzf').targets() end,
        ft = 'bzl',
        desc = '[B]azel [T]argets in file/package',
      },
      {
        '<leader>br',
        function() require('telescope_bazel.fzf').rule() end,
        ft = 'bzl',
        desc = '[B]azel targets from [R]ule under cursor',
      },
    },
  },
}
