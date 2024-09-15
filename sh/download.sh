#!/bin/bash
#
basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $basedir/libfuncs.sh
SetDirs
exit_if_not_mega

if [ ! -e "$workTreeTop/.plugins-mega/download"  ]; then
  echo ".plugins-mega/download not found"
  exit 1
elif [ ! -x "$workTreeTop/.plugins-mega/download"  ]; then
  echo ".plugins-mega/download is not set as executable"
  exit 1
fi

$workTreeTop/.plugins-mega/download $mainTreeTop/.mega
