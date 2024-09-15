#!/bin/bash
#
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
    myhash=${mylink##*/}
    subdir=${myhash:0:2}
    filename=${myfile##*/}
    destfile="$qroot"/"$subdir"/"$myhash"
    mkdir -p "$qroot"/"$subdir" #to avoid trial errors, such as nonexisted $qdir
    if [[ ! -e "$myfile" ]]; then
      ln -rsnf "$destfile" "$myfile"
      if [[ -e "$myfile" ]]; then
        echo "link: '$myfile' repaired"
      else
        echo "fail to repair '$myfile'"
      fi
    fi
  fi
}


if [[ -L "$mypath"  ]]; then
  if [[ ! "$mypath" == *".git/"* ]] && [[ ! "$mypath" == *".mega/"* ]]; then
    dealOneFile "$mypath"
  fi
elif [[ -d "$mypath" ]]; then
  echo "git-mega:searching for broken links ...."
  find "$mypath" -type l -print0 | while IFS= read -r -d '' myfile
  do
    if [[ ! "$myfile" == *".git/"* ]] && [[ ! "$myfile" == *".mega/"* ]]; then
      dealOneFile "$myfile"
    fi
  done
  echo -e "\nDone"
else
  echo "'$mypath' not found"
fi

echo -e "\nrun 'git mega download' and then 'git mega repair <dir>' if any repairs failed"
