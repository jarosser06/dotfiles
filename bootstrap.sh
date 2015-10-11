#!/bin/bash

if ! [[ -d ${HOME}/.dotfiles ]]; then
  DOTFILES_REPO="git@github.com:jarosser06/dotfiles.git"

  git clone $DOTFILES_REPO ${HOME}/.dotfiles
fi

DIRS="Go Projects .bin"

for dir in $DIRS;
do
  mkdir -p ${HOME}/${dir}
done

if ! [[ -d ${HOME}/.self_chef ]]; then
  ln -s ${HOME}/.dotfiles/chef ${HOME}/.self_chef
fi

${HOME}/.dotfiles/bin/boxer update
