---
title: DOT-VIM
section: 7
header: Dotfiles Manual
---

# NAME

dot-vim - Vim configuration reference

# DESCRIPTION

Neovim config at **~/.config/nvim/** using **lazy.nvim** plugin manager.
Leader key is **Space**.

# NAVIGATION

| Key | Action |
|-----|--------|
| **C-h / C-j / C-k / C-l** | Navigate between windows |
| **S-h** | Previous buffer |
| **S-l** | Next buffer |
| **C-d** | Half-page down (centered) |
| **C-u** | Half-page up (centered) |

# TELESCOPE (leader = Space)

| Key | Action |
|-----|--------|
| **\<leader\>ff** | Find files |
| **\<leader\>fg** | Live grep |
| **\<leader\>fb** | Buffers |
| **\<leader\>fr** | Recent files |
| **\<leader\>fh** | Help tags |

Ignores node_modules, .git/, and target/ directories.

# FILE EXPLORER

| Key | Action |
|-----|--------|
| **\<leader\>e** | Toggle nvim-tree (width 35) |

# LSP

Installed servers: **pyright**, **rust_analyzer**, **gopls**, **ts_ls**

Managed via Mason + mason-lspconfig.

| Key | Action |
|-----|--------|
| **gd** | Go to definition |
| **gr** | Go to references |
| **K** | Hover documentation |
| **\<leader\>ca** | Code action |
| **\<leader\>rn** | Rename symbol |
| **\<leader\>ds** | Document symbols |
| **[d** | Previous diagnostic |
| **]d** | Next diagnostic |

# COPILOT

Auto-triggered inline suggestions in insert mode.

| Key | Action |
|-----|--------|
| **C-y** | Accept suggestion |
| **M-]** | Next suggestion |
| **M-[** | Previous suggestion |
| **C-e** | Dismiss suggestion |

Panel mode is disabled.

# COPILOT CHAT

| Key | Mode | Action |
|-----|------|--------|
| **\<leader\>cc** | n, v | Open Copilot Chat |
| **\<leader\>ce** | v | Explain selection |
| **\<leader\>cf** | v | Fix selection |
| **\<leader\>cr** | v | Review selection |

Chat window opens as a vertical split (40% width).

# EDITING

**gc**
:   Toggle comment (Comment.nvim). Works in normal and visual mode.

**ys** / **ds** / **cs**
:   Add / delete / change surrounds (nvim-surround).

Auto-pairs enabled for brackets, quotes, etc.

# VISUAL MODE

| Key | Action |
|-----|--------|
| **J** | Move selected lines down |
| **K** | Move selected lines up |
| **p** | Paste without yanking replaced text |

# OPTIONS

| Option | Value |
|--------|-------|
| **number** | true |
| **relativenumber** | true |
| **expandtab** | true |
| **shiftwidth / tabstop** | 4 (2 for ts/js/json/yaml/html/css) |
| **smartindent** | true |
| **wrap** | false |
| **scrolloff** | 8 |
| **ignorecase + smartcase** | true |
| **splitbelow / splitright** | true |
| **clipboard** | unnamedplus (system) |
| **undofile** | true |
| **termguicolors** | true |
| **updatetime** | 250ms |
| **timeoutlen** | 300ms |
| **cursorline** | true |
| **signcolumn** | yes |

# PLUGINS

- **lazy.nvim** — plugin manager
- **telescope.nvim** + fzf-native — fuzzy finder
- **nvim-tree.lua** — file explorer
- **nvim-lspconfig** + mason — LSP
- **copilot.lua** — GitHub Copilot
- **CopilotChat.nvim** — Copilot Chat
- **nvim-treesitter** — syntax highlighting
- **Comment.nvim** — commenting (gc)
- **nvim-surround** — surround editing
- **nvim-autopairs** — auto-close brackets
- **gitsigns.nvim** — git indicators in sign column
- **which-key.nvim** — keybinding hints
- **lualine.nvim** — status line
- **alpha-nvim** — dashboard
- **everforest** — color scheme

# FILES

*~/.config/nvim/init.lua*, *~/.config/nvim/lua/**

# SEE ALSO

**dot-dotfiles**(7), **nvim**(1)
