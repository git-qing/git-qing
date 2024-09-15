#!/bin/bash
#
basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $basedir/libfuncs.sh
SetDirs
exit_if_not_mega
#
chmod_w_dirs
mkdir -p "$tmpdir"
#
#pre-commit operations
#
# get staged files except those deleted
ierr=$(git diff --diff-filter=d --cached --name-only 1>$tmpdir/files.changed 2>/dev/null; echo $? )
if [ $ierr -ne 0 ]; then
  echo "fatal: fail to run git diff --diff-filter=d --cached --name-only"
  exit 1 #stop the commit
fi

while read line; do  # <$tmpdir/files.changed
  if [ ! -z "$line" ]; then
    myfile=$(echo "${line}" |xargs)  #trim leading whitespaces
    if [ -d $myfile ]; then continue; fi #skip to next line if it is a directory
    if $(deposit_if_mega_file "$myfile"); then
      git add "$myfile"  #now $myfile is a link, stage the typechange
    fi
  fi
done < $tmpdir/files.changed
git add ${workTreeTop}/.gitattributes
exit 0
