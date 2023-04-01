#!/bin/bash
#
basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $basedir/libfuncs.sh
SetDirs
#
mydir="$1"
if [[ -z "$mydir" ]] ; then
  if [[ -d "$qroot" ]]; then
    mydir="$qroot"
  else
    echo "run 'git qing verify' under a git-qing repo"
    echo "or 'git qing verify <dir|file> if not a git-qing repo"
    exit
  fi
fi
if [[ -f "$mydir" ]]; then
  ${basedir}/verifyOneFile.sh $mydir
elif [[ ! -d "$mydir" ]]; then
  echo "'$mydir' not found!"
  echo "run 'git qing verify' under a git-qing repo"
  echo "or 'git qing verify <dir|file> if not a git-qing repo"
else
  find "$mydir" -type f -print0 | while IFS= read -r -d '' myfile
  do
    ${basedir}/verifyOneFile.sh "$myfile"
  done
  echo "Done."
fi
