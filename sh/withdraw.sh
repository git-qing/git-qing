#!/bin/bash
#   Given a directory or link, replace all links with their actual files
basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $basedir/libfuncs.sh
SetDirs
exit_if_not_mega

mypath="$1"

dealOneFile()
{
  local myfile="$1"
  if $(is_link_to_mega_space "$myfile"); then
    mylink=$(readlink "$myfile")
    pushd $(pwd) 1>/dev/null 2>/dev/null
    cd $(dirname $myfile) 1>/dev/null 2>/dev/null
    if [[ $? -eq 0  ]]; then
      rm -f "${myfile##*/}" 2>/dev/null
      cp -p "$mylink" "${myfile##*/}" 2>/dev/null
      chmod +w "${myfile##*/}"
      echo "'$1' withdrawn from the mega space"
    else
      echo "fail to withdraw '$myfile', broken link, run 'git mega repair'"
    fi
    popd 1>/dev/null
  fi
}

if [[ -L "$mypath"  ]]; then
  if [[ ! "$mypath" == *".git/"* ]] && [[ ! "$mypath" == *".mega/"* ]]; then
    dealOneFile "$mypath"
  fi
elif [[ -d "$mypath" ]]; then
  echo "git-mega:searching for links ..."
  find "$mypath" -type l -print0 | while IFS= read -r -d '' myfile
  do
    if [[ ! "$myfile" == *".git/"* ]] && [[ ! "$myfile" == *".mega/"* ]]; then
      dealOneFile "$myfile"
    fi
  done
  echo -e "\nDone"
else
  echo "'$mypath' is not a directory nor a link to a mega file"
  exit
fi
