#!/bin/bash

function ffupdate() {
  pushd ${HOME}/.fastfood &> /dev/null
  git pull
  popd &> /dev/null
}
