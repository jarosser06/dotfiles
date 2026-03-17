---
title: DOT
section: 1
header: Dotfiles Manual
---

# NAME

dot - dotfiles manager

# SYNOPSIS

**dot** *command* [*args*]

# DESCRIPTION

Manages dotfiles stored in **~/.dotfiles**. Symlinks config files into
place, adds new files to the repo, and provides access to personal
man pages.

The repo location is resolved by following the symlink at
**~/.local/bin/dot** back to its real path.

# COMMANDS

**install**
:   Read **dotfiles.map** and create symlinks for each entry. Skips
    destinations that already exist unless they are already the correct
    symlink. Creates parent directories as needed.

    Also installs Starship (via Homebrew) if not present, and rebuilds
    man pages if pandoc is available.

**add** *path*
:   Move *path* into the dotfiles repo and replace the original with a
    symlink. The leading dot is stripped from the filename. Appends the
    new entry to **dotfiles.map**.

    Example:

        dot add ~/.tool.conf
        # copies to ~/.dotfiles/tool.conf
        # symlinks ~/.tool.conf → ~/.dotfiles/tool.conf
        # appends "tool.conf:~/.tool.conf" to dotfiles.map

**list**
:   Print the contents of **dotfiles.map**.

**help** [*topic*]
:   Show the man page for **dot-***topic*. Without an argument, shows
    **dot-dotfiles**(7) (the index page).

    Available topics: bash, dotfiles, scripts, starship, tmux, vim.

# DOTFILES MAP

The file **dotfiles.map** drives **dot install**. Each line has the format:

    source:destination

Where *source* is relative to the repo root and *destination* is an
absolute path (~ is expanded). Lines starting with **#** are comments.
Blank lines are skipped.

# FILES

*~/.dotfiles/dotfiles.map*
:   Symlink mapping file.

*~/.dotfiles/man/*
:   Man page sources and built pages.

*~/.local/bin/dot*
:   Symlink to the dot script.

# SEE ALSO

**dot-dotfiles**(7), **dot-vim**(7), **dot-tmux**(7), **dot-bash**(7),
**dot-scripts**(7), **dot-starship**(7)
