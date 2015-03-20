#!/bin/bash

DOTFILES="git@github.com:jarosser06/dotfiles.git"

git clone $DOTFILES ${HOME}/.dotfiles

DIRS="Go Projects"

for dir in $DIRS;
do
  mkdir -p ${HOME}/${dir}
done

${HOME}/.dotfiles/bin/boxer update
