---
title: DOT-DOTFILES
section: 7
header: Dotfiles Manual
---

# NAME

dot-dotfiles - overview of the dotfiles repo and manual pages

# SYNOPSIS

**man** dot-*topic*

**dot help** [*topic*]

# DESCRIPTION

Personal dotfiles managed from **~/.dotfiles** and symlinked into place
via **dot install**. This page is the index for all dotfiles man pages.

# AVAILABLE PAGES

**dot-vim**(7)
:   Vim configuration — keybindings, LSP, plugins

**dot-tmux**(7)
:   Tmux configuration and cheatsheet

**dot-bash**(7)
:   Shell configuration — aliases, functions, loading order

**dot-scripts**(7)
:   Custom scripts — dot, attach_env, docker-cleanup

**dot-starship**(7)
:   Starship prompt — Gruvbox theme, segments, git symbols

# REPO STRUCTURE

    ~/.dotfiles/
      bashrc              Shell entry point
      bash_custom/        Modular shell config (aliases, exports, etc.)
      bash_profile        Login shell setup
      nvim/               Neovim config (lazy.nvim)
      tmux.conf           Tmux config
      starship.toml       Starship prompt config
      gitconfig           Git config
      bin/                Custom scripts
      dot                 Dotfiles manager
      dotfiles.map        Source:destination symlink map

# THE DOT COMMAND

**dot install**
:   Symlink all entries from dotfiles.map

**dot add** *path*
:   Move a file into the repo and replace with symlink

**dot list**
:   Print dotfiles.map

**dot help** [*topic*]
:   Show man page for *topic* (default: dotfiles)

# SEE ALSO

**dot-vim**(7), **dot-tmux**(7), **dot-bash**(7), **dot-scripts**(7), **dot-starship**(7)
