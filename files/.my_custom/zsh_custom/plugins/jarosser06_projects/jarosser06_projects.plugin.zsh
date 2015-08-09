function update_project() {
  project_name=$1

  if [[ -z $project_name ]]; then
    echo "You must pass a project name"
    return 1
  fi

  if [[ -d ${PROJECTS_DIR}/${project_name} ]]; then
    pushd ${PROJECTS_DIR}/${project_name} &> /dev/null
    echo "Updating ${project_name}..."
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
    echo "Cloning ${project}..."
    git clone git@github.com:${project}
    popd &> /dev/null
    return 0
  fi
}

function update_github_projects() {
  project_list=$(jq ".github[]" ${HOME}/.projects.json)
  for project in $project_list;
  do
    ## Strip the first and last quote
    project="${project%\"}"
    project="${project#\"}"

    ## Strip the org name
    prj_name=${project##*/}

    if [[ -d ${PROJECTS_DIR}/${prj_name} ]]; then
      update_project $prj_name
      echo
    else
      clone_github_project $project
      echo
    fi
  done
}
