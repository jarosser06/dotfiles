DOTFILES=${HOME}/.dotfiles

function update_dotfiles {
  pushd $DOTFILES &> /dev/null
  git pull
  popd &> /dev/null
}

function trim_branches {
  git branch --merged master | grep -v "\* master" | xargs -n 1 git branch -d
}
