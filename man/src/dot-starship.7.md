---
title: DOT-STARSHIP
section: 7
header: Dotfiles Manual
---

# NAME

dot-starship - Starship prompt configuration

# DESCRIPTION

Starship cross-shell prompt configured at **~/.config/starship.toml**.
Uses the **Gruvbox Dark** color palette.

# PROMPT FORMAT

The prompt renders left-to-right with powerline-style separators:

    [hostname] [directory] [git branch + status]
    [character]

The character changes icon and color on success vs error.

# COLOR PALETTE (GRUVBOX DARK)

| Name | Hex | Usage |
|------|-----|-------|
| **color_orange** | #d65d0e | Hostname background |
| **color_yellow** | #d79921 | Directory background |
| **color_aqua** | #689d6a | Git info background |
| **color_blue** | #458588 | Success prompt character |
| **color_red** | #cc241d | Error prompt character |
| **color_fg0** | #fbf1c7 | Foreground text |
| **color_green** | #98971a | (available) |
| **color_purple** | #b16286 | (available) |

# SEGMENTS

**hostname**
:   Always shown (not SSH-only). Orange background.

**directory**
:   Full path (truncate_to_repo = false). Yellow background.

**git_branch**
:   Branch name with  icon. Aqua background.

**git_status**
:   Compact symbols on aqua background:

    | Symbol | Meaning |
    |--------|---------|
    | **+** | Staged changes |
    | **\*** | Modified files |
    | **≡** | Stashed changes |

    Untracked, renamed, deleted, and conflicted are hidden (empty string).

**character**
:   Nerd Font icons — changes color on error.

**cmd_duration**
:   Shown in yellow when command takes notable time.

**battery**
:   Minimal format: • full, ⇡ charging, ⇣ discharging.

**python**
:   Uses python3 binary for version detection.

# FILES

*~/.config/starship.toml*

# SEE ALSO

**dot-dotfiles**(7), **starship**(1)
