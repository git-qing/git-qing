#!/bin/bash
#
basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $basedir/libfuncs.sh
SetDirs
#
myfile=${1%/} #remove traing / if it is there
if [ ! -f "$myfile" ]; then
  echo "'$myfile' is not a regular file"
  exit 1
fi

${MEGA_SHA_CMD} $myfile | cut -d ' ' -f1
