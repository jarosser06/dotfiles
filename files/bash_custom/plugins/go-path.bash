#!/bin/bash

function cd() {
  builtin cd "$@"

  if [ -a "${PWD}/.gopath" ]; then
    export GOPATH=${PWD}/.gopath
  fi
}
