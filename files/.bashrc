# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Pre and Post configs
BASH_CUSTOM_PRE_CONFIG=${HOME}/.bash_custom/local_pre
BASH_CUSTOM_POST_CONFIG=${HOME}/.bash_custom/local_post

# Source Local Pre File
if [ -a $BASH_CUSTOM_PRE_CONFIG ]; then
  source $BASH_CUSTOM_PRE_CONFIG
fi

# User specific aliases and functions
source ${HOME}/.bash_custom/git-completion.sh
source ${HOME}/.bash_custom/env_vars
source ${HOME}/.bash_custom/aliases

# Load any plugins in the plugins directory
for plugin in ${HOME}/.bash_custom/plugins/*;
do
  source $plugin
done

## If the secrets file exists then source it
if [ -a ${HOME}/.bash_custom/secrets ]; then
  source ${HOME}/.bash_custom/secrets
fi

## Set longer history
export HISTSIZE=20000

## Share history
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend

export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"

# Source Local Post File
if [ -f $BASH_CUSTOM_POST_CONFIG ]; then
  source $BASH_CUSTOM_POST_CONFIG
fi
