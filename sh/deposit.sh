#!/bin/bash
#
basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $basedir/libfuncs.sh
SetDirs
exit_if_not_mega

chmod_w_dirs

mypath="$1"
if [[ -e "$mypath" ]]; then
  echo "Searching for large or non-text files ...."
  find "$mypath" -type f -print0 | while IFS= read -r -d '' myfile
  do
    if [[ ! "$myfile" == *".git/"* ]] && [[ ! "$myfile" == *".mega/"* ]]; then
      deposit_if_mega_file "$myfile" >/dev/null
    fi
  done
  echo -e "\nDone"
else
  echo "'$mypath' not found"
  exit
fi
