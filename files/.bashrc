# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions

# Get custom env vars
PS1='[\u@\h] \w\[\033[33m\]$(__git_ps1)\[\033[00m\]\$ '
GIT_PS1_SHOWDIRTYSTATE=true

alias projupdate=update_github_projects
alias berks=guard-berks
source ${HOME}/.bash_custom/git-completion.sh
source ${HOME}/.bash_custom/env_vars
source ${HOME}/.bash_custom/aliases

for plugin in $(ls ${HOME}/.bash_custom/plugins);
do
  source ${HOME}/.bash_custom/plugins/${plugin}
done

## If the secrets file exists then source it
if [ -a ${HOME}/.bash_custom/secrets ]; then
  source ${HOME}/.bash_custom/secrets
fi

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
