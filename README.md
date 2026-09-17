# dotfiles

Personal tmux and Neovim configuration.

## Contents

- `.tmux.conf` — tmux config: `C-a` prefix, vi-style copy-mode, tmux-aware pane
  navigation, dracula theme, and an active-pane indicator in the pane border.
- `.config/nvim/` — Neovim config (lazy.nvim-based), built on a kickstart.nvim
  layout:
  - `lua/robert/core/` — options, keymaps, autocmds, diagnostics
  - `lua/robert/plugins/` — one file per plugin, notably:
    - `oil.nvim` for file browsing, with a git branch/dirty indicator
    - `vim-rooter` for automatic `:lcd` to the project root
    - `smart-splits.nvim` for tmux-aware window navigation
    - `telescope.nvim` for fuzzy finding, git grep, and LSP pickers
    - `vim-fugitive` / `gitsigns.nvim` for git
    - `glow.nvim` for Markdown preview
  - `lua/robert/util/` — small shared modules used across plugin files
    (e.g. `nav.lua` for window-navigation keymaps, `clipboard.lua` for
    copy-to-clipboard-with-echo)

## Usage

Symlink (or copy) into place:

```sh
ln -s "$(pwd)/.tmux.conf" ~/.tmux.conf
ln -s "$(pwd)/.config/nvim" ~/.config/nvim
```

tmux plugins are managed by [TPM](https://github.com/tmux-plugins/tpm); once
`.tmux.conf` is in place, install `~/.tmux/plugins/tpm` and run `prefix + I`
inside tmux to install them.
