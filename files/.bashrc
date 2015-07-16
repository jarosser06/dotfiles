# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions

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
