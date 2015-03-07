#!/bin/bash

DIRS=".bin .bash_custom Go Projects"

for dir in $DIRS;
do
  mkdir -p ${HOME}/${dir}
done

bin/boxer update
