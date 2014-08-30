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

  prj_name=${project##*/}
  if [ -d ${PROJECTS_DIR}/${prj_name} ]; then
    echo "Project ${project} already exists!!"
    return 0
  else
    pushd $PROJECTS_DIR &> /dev/null
    git clone git@github.com:${project}
    popd &> /dev/null
    return 0
  fi
}

function update_projects() {
  hosting_site=$1

  if [ -z $hosting_site ]; then
    echo "You must pass a project domain"
    return 1
  fi

  project_list=$(jq ".${hosting_site}[]" ${HOME}/.projects.json)
  for project in $project_list;
  do
    update_project $project
  done
}
