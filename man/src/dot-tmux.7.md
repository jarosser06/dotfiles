---
title: DOT-TMUX
section: 7
header: Dotfiles Manual
---

# NAME

dot-tmux - tmux configuration and cheatsheet

# DESCRIPTION

Tmux config at **~/.tmux.conf**. Uses vi mode for copy-mode keys.
True color support enabled via *tmux-256color* and RGB overrides.

# CUSTOM SETTINGS

**default-terminal**
:   tmux-256color (with xterm-256color RGB override)

**mode-keys**
:   vi

**status-right**
:   hostname (#h)

# PREFIX KEY

Default prefix is **C-b** (not remapped).

# CHEATSHEET

## Sessions

| Key | Action |
|-----|--------|
| **prefix d** | Detach |
| **prefix s** | List sessions |
| **prefix $** | Rename session |
| **prefix (** | Previous session |
| **prefix )** | Next session |

## Windows

| Key | Action |
|-----|--------|
| **prefix c** | New window |
| **prefix ,** | Rename window |
| **prefix n** | Next window |
| **prefix p** | Previous window |
| **prefix w** | List windows |
| **prefix &** | Kill window |
| **prefix 0-9** | Select window by number |

## Panes

| Key | Action |
|-----|--------|
| **prefix %** | Split vertical |
| **prefix "** | Split horizontal |
| **prefix o** | Next pane |
| **prefix x** | Kill pane |
| **prefix z** | Toggle zoom |
| **prefix {** | Swap pane left |
| **prefix }** | Swap pane right |
| **prefix arrow** | Navigate panes |

## Copy Mode (vi keys)

| Key | Action |
|-----|--------|
| **prefix [** | Enter copy mode |
| **v** | Begin selection |
| **y** | Copy selection |
| **q** | Exit copy mode |
| **/** | Search forward |
| **?** | Search backward |
| **n** | Next match |
| **N** | Previous match |

# FILES

*~/.tmux.conf*

# SEE ALSO

**dot-dotfiles**(7), **tmux**(1)
