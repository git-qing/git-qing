#!/bin/bash
#
basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $basedir/libfuncs.sh
SetDirs
exit_if_not_mega

if [ ! -e "$workTreeTop/.plugins-mega/upload"  ]; then
  echo ".plugins-mega/upload not found"
  exit 1
elif [ ! -x "$workTreeTop/.plugins-mega/upload"  ]; then
  echo ".plugins-mega/upload is not set as executable"
  exit 1
fi

$workTreeTop/.plugins-mega/upload $mainTreeTop/.mega
