---
title: DOT-SCRIPTS
section: 7
header: Dotfiles Manual
---

# NAME

dot-scripts - custom scripts reference

# DESCRIPTION

Scripts in **~/.dotfiles/bin/** are symlinked to **~/.local/bin/** by
**dot install** and available on PATH.

# DOT

The dotfiles manager. See **dot-dotfiles**(7) for full usage.

    dot install          Symlink all dotfiles
    dot add <path>       Add file to repo
    dot list             Print dotfiles.map
    dot help [topic]     Show man page

# ATTACH_ENV

Attach to a running devcontainer's shell.

    attach_env                  Auto-detect from current directory
    attach_env <project>        Attach to named project

Searches for running containers matching the project name using
multiple patterns (Docker Compose naming conventions). Falls back
to the current directory name if no argument given.

Requires **.devcontainer/** in the project root for auto-detection.

# DOCKER-CLEANUP

Remove all stopped (exited) Docker containers.

    docker-cleanup

No arguments. Finds containers with status=exited and removes them.

# FILES

*~/.local/bin/dot*, *~/.local/bin/attach_env*, *~/.local/bin/docker-cleanup*

# SEE ALSO

**dot-dotfiles**(7), **dot-bash**(7)
