#!/bin/bash

if ! [[ -d ${HOME}/.dotfiles ]]; then
  DOTFILES_REPO="git@github.com:jarosser06/dotfiles.git"

  git clone $DOTFILES_REPO ${HOME}/.dotfiles
fi

if ! [[ -d ${HOME}/.tmux/plugins/tpm ]]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Add extra directories
DIRS="Go Projects .bin"

for dir in $DIRS;
do
  mkdir -p ${HOME}/${dir}
done

${HOME}/.dotfiles/bin/boxer update
