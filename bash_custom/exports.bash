export EDITOR=nvim
export GOPATH="$HOME/Go"
export PROJECTS_DIR="$HOME/Projects"
export MANPATH="$HOME/.dotfiles/man:${MANPATH:-:}"
[[ "$(uname)" == "Darwin" ]] && export LD_LIBRARY_PATH=/usr/local/lib
