#!/bin/bash

function goproject() {
  if [ -z $1 ]; then
    echo "Must pass a project name"
  else
    PROJ_PATH=$1
    PROJ_BASE_DIR=${GOPATH}/src/github.com/
    PROJ_DIR=${PROJ_BASE_DIR}/${PROJ_PATH}
    mkdir -p $PROJ_BASE_DIR &> /dev/null
    git clone git@github.com:jarosser06/goproject.git $PROJ_DIR &> /dev/null

    cd $PROJ_DIR
    rm -rf .git &> /dev/null

    # Split the path into an array to grab the name
    IFS='/' read -r -a split_name <<< $PROJ_PATH

    # Get the name of the project
    PROJ_NAME=${split_name[-1]}

    PROJ_TEMPLATES="README.md Makefile"
    for temp in $PROJ_TEMPLATES
    do
     sed -i "s/GOPROJECT/${PROJ_NAME}/g" ${temp}
    done
    git init

    echo "Project ${PROJ_NAME} created"
  fi
}

function gotoproject() {
  if [ -z $1 ]; then
    echo "Must pass a project"
  else
    PROJ=${HOME}/Go/src/github.com/${1}

    if [ -d $PROJ ]; then
      cd $PROJ
    else
      echo "Project ${1} doesn't exist"
    fi
  fi
}
