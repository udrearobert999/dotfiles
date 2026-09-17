# dotfiles

Personal tmux and Neovim configuration.

## TMUX

### Prerequisites

- [tmux](https://github.com/tmux/tmux) (3.2+, for `pane-border-format`)
- [TPM](https://github.com/tmux-plugins/tpm) — tmux plugin manager, not
  included in this repo (see Usage below)
- `git` — TPM clones plugins with it

### Contents

- `.tmux.conf` — `C-a` prefix, vi-style copy-mode, tmux-aware pane
  navigation, dracula theme, and an active-pane indicator in the pane border.
  Declares (via TPM) `tmux-resurrect`, `tmux-continuum`, `dracula/tmux`,
  `tmux-yank`, `tmux-copycat`.

## NVIM

### Prerequisites

- [Neovim](https://neovim.io/) 0.11+ (uses `vim.lsp.config`/`vim.lsp.enable`
  and `nvim-treesitter`'s `main` branch)
- `git` — lazy.nvim bootstraps and clones plugins with it
- A C compiler (`cc`/`gcc`/`clang`) — needed to build treesitter parsers
- [ripgrep](https://github.com/BurntSushi/ripgrep) — used by Telescope's
  `live_grep`/`grep_string`
- [Node.js](https://nodejs.org/) — required by the npm-based LSP/formatter
  tools Mason installs (`typescript-language-server`, `eslint-lsp`,
  `prettierd`)
- [glow](https://github.com/charmbracelet/glow) — required by `glow.nvim`
  for Markdown preview (e.g. `brew install glow`)
- A [Nerd Font](https://www.nerdfonts.com/) in your terminal (config sets
  `vim.g.have_nerd_font = true`)
- `make` — optional, builds `telescope-fzf-native` for faster sorting

### Contents

- `.config/nvim/` — Neovim config (lazy.nvim-based), built on a
  kickstart.nvim layout:
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

Setting this up on a new machine:

1. Install the prerequisites listed above (e.g. via Homebrew on macOS):

   ```sh
   brew install tmux neovim git ripgrep node glow
   ```

2. Clone this repo and symlink the configs into place:

   ```sh
   git clone https://github.com/udrearobert999/dotfiles.git ~/dotfiles
   ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
   ln -s ~/dotfiles/.config/nvim ~/.config/nvim
   ```

3. Install TPM and the tmux plugins:

   ```sh
   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
   ```

   Start tmux, then press `prefix + I` (capital i) to fetch the plugins
   declared in `.tmux.conf`.

4. Launch `nvim`. `lazy.nvim` bootstraps itself on first run, installs all
   plugins, and `mason-tool-installer` fetches the configured LSP servers
   and formatters automatically. Treesitter parsers install on first run
   too; if any are missing, run `:TSUpdate`.
