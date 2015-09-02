#!/bin/bash

DOTFILES=${HOME}/.dotfiles

function update_dotfiles {
  pushd $DOTFILES &> /dev/null
  git pull
  popd &> /dev/null
}

function source_if_exists {
  sh_file=$1

  if [ -a $sh_file ]; then
    source $sh_file
  fi
}

function trim_branches {
  git branch --merged master | grep -v "\* master" | xargs -n 1 git branch -d
}
