#bin/bash

function goproject() {
  if [ -z $1 ]; then
    echo "Must pass a project name"
  else
    PROJ_NAME=$1
    PROJ_BASE_DIR=${GOPATHsrc/github.com/jarosser06
    PROJ_DIR=${PROJ_BASE_DIR${PROJ_NAME}
    mkdir -p $PROJ_BASE_DIR &>dev/null
    git clone git@github.com:jarosser0goproject.git $PROJ_DIR &> /dev/null

    cd $PROJ_DIR
    rm -rf .git &>dev/null

    PROJ_TEMPLATES="README.md scriptmake.sh"
    for temp in $PROJ_TEMPLATES
    do
      sed -i GOPROJECT/${PROJ_NAME}/g ${temp}
    done
    git init

    echo "Project ${PROJ_NAME} created"
  fi
}
