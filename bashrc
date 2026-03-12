# .bashrc

# Source global definitions
[ -f /etc/bashrc ] && . /etc/bashrc

# Source all bash_custom files
for f in "$HOME/.bash_custom/"*.bash; do
  [ -f "$f" ] && source "$f"
done

# Machine-specific overrides (gitignored)
[ -f "$HOME/.bash_custom/local.bash" ] && source "$HOME/.bash_custom/local.bash"

# Secrets (gitignored)
[ -f "$HOME/.bash_custom/secrets" ] && source "$HOME/.bash_custom/secrets"

# Cargo env
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Starship prompt
eval "$(starship init bash)"

# bash-preexec (must be sourced last)
[ -f "$HOME/.bash_custom/bash-preexec.sh" ] && source "$HOME/.bash_custom/bash-preexec.sh"
