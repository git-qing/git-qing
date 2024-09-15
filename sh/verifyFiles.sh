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
    echo "run 'git mega verify' under a git-mega repo"
    echo "or 'git mega verify <dir|file> if not a git-mega repo"
    exit
  fi
fi
if [[ -f "$mydir" ]]; then
  ${basedir}/verifyOneFile.sh $mydir
elif [[ ! -d "$mydir" ]]; then
  echo "'$mydir' not found!"
  echo "run 'git mega verify' under a git-mega repo"
  echo "or 'git mega verify <dir|file> if not a git-mega repo"
else
  find "$mydir" -type f -print0 | while IFS= read -r -d '' myfile
  do
    ${basedir}/verifyOneFile.sh "$myfile"
  done
  echo "Done."
fi
