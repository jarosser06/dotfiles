#!/bin/bash

DOTFILES=${HOME}/.dotfiles

function update_dotfiles {
  pushd $DOTFILES &> /dev/null
  git pull
  popd &> /dev/null
}
