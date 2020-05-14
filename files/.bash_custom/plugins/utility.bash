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
  if ! [[ "$(git branch | grep \* | grep -v master)" == "" ]]; then
    echo "Current branch is not master ... not trimming"
    return 1
  fi
  merged_branches=$(git branch --merged master | grep -v master)
  if [[ -z $merged_branches ]]; then
    echo "All clean!"
  else
    git branch --merged master | grep -v "\* master" | xargs -n 1 git branch -d
  fi
}

function rm_by_inode {
  inode=$1
  if [ -z $inode ]; then
    echo "must provide inode"
  fi

  find . -inum $inode -exec rm -i {} \;
}

function kill_all_containers {
  for container in $(docker ps | awk '{ print $1 }'); do
    if [[ $container == 'CONTAINER' ]]; then
      continue
    fi
    docker kill $container
  done
}
