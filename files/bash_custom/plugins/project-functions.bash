#!/bin/bash

function update_project() {
  project_name=$1

  if [ -z $project_name ]; then
    echo "You must pass a project name"
    return 1
  fi

  if [ -d ${PROJECTS_DIR}/${project_name} ]; then
    pushd ${PROJECTS_DIR}/${project_name} &> /dev/null
    git pull
    popd &> /dev/null
    return 0
  else
    echo "Project ${project_name} does not exist"
    return 1
  fi
}

function clone_github_project() {
  project=$1

  if [ -z $project ]; then
    echo "You must pass a project name"
    return 1
  fi

  if [ -d ${PROJECTS_DIR}/${project} ]; then
    echo "Project ${project} already exists!!"
    return 0
  else
    pushd $PROJECTS_DIR &> /dev/null
    git clone git@github.com:${project}
    popd &> /dev/null
    return 0
  fi
}
