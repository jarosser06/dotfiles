---
title: DOT-BASH
section: 7
header: Dotfiles Manual
---

# NAME

dot-bash - shell configuration reference

# DESCRIPTION

Bash configuration split across **~/.bashrc** and modular files in
**~/.bash_custom/**.

# LOADING ORDER

1. **~/.bash_profile** — sources ~/.bashrc
2. **~/.bashrc** — sources all ~/.bash_custom/*.bash files, then:
   - **local.bash** — machine-specific overrides (gitignored)
   - **secrets** — credentials (gitignored)
   - **~/.cargo/env** — Rust toolchain
   - **starship init** — prompt initialization
   - **bash-preexec.sh** — preexec hooks (must be last)

# MODULAR FILES

**aliases.bash**
:   Shell aliases (see ALIASES below)

**aws.bash**
:   AWS helper functions and aliases

**colors.bash**
:   Terminal color definitions

**completions.bash**
:   Bash completions setup

**exports.bash**
:   Environment variables (EDITOR, GOPATH, MANPATH, etc.)

**git-completion.bash**
:   Git tab completion

**history.bash**
:   History configuration

**path.bash**
:   PATH construction

# ALIASES

| Alias | Expansion |
|-------|-----------|
| **ll** | ls -lh |
| **vim** | nvim |
| **pfiles** | lsof -a -p |
| **ports-listening** | netstat -an -ptcp \| grep LISTEN |

# AWS FUNCTIONS

**s3-ls-buckets**
:   List all S3 bucket names

**s3-ls-bucket** *name*
:   List contents of an S3 bucket recursively

**active_aws_account**
:   Print current AWS account ID (requires jq)

**cf-ls-stacks**
:   List CloudFormation stacks with status

# HISTORY

- **HISTSIZE** = 20000
- **HISTCONTROL** = ignoredups:erasedups
- Append mode enabled (histappend)
- Shared across terminals via history -a/-c/-r in PROMPT_COMMAND

# ENVIRONMENT VARIABLES

| Variable | Value |
|----------|-------|
| **EDITOR** | nvim |
| **GOPATH** | ~/Go |
| **PROJECTS_DIR** | ~/Projects |

# PATH ADDITIONS

~/.local/bin, ~/.bin, ~/.cargo/bin, ~/Go/bin, /usr/local/go/bin,
/usr/local/node/bin (if present)

# LOCAL OVERRIDES

Place machine-specific config in **~/.bash_custom/local.bash** (gitignored).
Place secrets in **~/.bash_custom/secrets** (gitignored).

# FILES

*~/.bashrc*, *~/.bash_profile*, *~/.bash_custom/**

# SEE ALSO

**dot-dotfiles**(7), **dot-scripts**(7), **bash**(1)
