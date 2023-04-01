#!/bin/bash
#
basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $basedir/libfuncs.sh
SetDirs
exit_if_not_qing

if [ ! -e "$workTreeTop/.plugins-qing/upload"  ]; then
  echo ".plugins-qing/upload not found"
  exit 1
elif [ ! -x "$workTreeTop/.plugins-qing/upload"  ]; then
  echo ".plugins-qing/upload is not set as executable"
  exit 1
fi

$workTreeTop/.plugins-qing/upload $mainTreeTop/.qing
