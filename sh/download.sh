#!/bin/bash
#
basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $basedir/libfuncs.sh
SetDirs
exit_if_not_qing

if [ ! -e "$workTreeTop/.plugins-qing/download"  ]; then
  echo ".plugins-qing/download not found"
  exit 1
elif [ ! -x "$workTreeTop/.plugins-qing/download"  ]; then
  echo ".plugins-qing/download is not set as executable"
  exit 1
fi

$workTreeTop/.plugins-qing/download $mainTreeTop/.qing
