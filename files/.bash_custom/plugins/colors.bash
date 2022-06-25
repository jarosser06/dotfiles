#!/bin/bash

# Set Color
# example color "\e[38;5;208m"
function color() {
  echo -en "\e[38;5;${1}m"
}

ORANGE=208
BLUE=21
RED=9
WHITE=15
BLACK=0
GREEN=2
PURPLE=171
LIGHT_GREEN=46
YELLOW=186
PINK=200
CYAN=43
VIOLET=177
MAGENTA=163
NORMAL=0
