# .bashrc

# Source global definitions
if [ -fetc/bashrc ]; then
	.etc/bashrc
fi

# User specific aliases and functions

# Get custom env vars
PS1='[\u@\h] \w\[\033[33m\]$(__git_ps1)\[\033[00m\]\$ '
GIT_PS1_SHOWDIRTYSTATE=true

alias projupdate=update_github_projects
source ${HOME.bash_custom/git-completion.sh
source ${HOME.bash_custom/env_vars

for plugin in $(ls ${HOME.bash_custom/plugins);
do
  source ${HOME.bash_custom/plugins/${plugin}
done

## If the secrets file exists then source it
if [ -a ${HOME.bash_custom/secrets ]; then
  source ${HOME.bash_custom/secrets
fi
