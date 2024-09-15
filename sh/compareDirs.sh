#!/bin/bash
#  find those mega files in srcdir but not in dstdir
basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $basedir/libfuncs.sh

srcdir=${1%/} #remove trailng / 
dstdir=${2%/} #remove trailng /
[[ ! -d "$srcdir" ]] && echo "'$srcdir' not found" && exit 1
[[ ! -d "$dstdir" ]] && echo "'$dstdir' not found" && exit 1

echo "The following REGULAR files not found in $dstdir:"
find "$srcdir" -type f -print0 | while IFS= read -r -d '' srcfile
do
  fhash=${srcfile##*/}
  dstfile=$(find "$dstdir" -name $fhash 2>/dev/null)
  if [ -n "$destfile" ]; then
    filesize=$(du -b "$dstfile" 2>/dev/null|cut -f1 2>/dev/null)
    if [ -z $filesize ]; then filesize=0; fi
    sizestring=$(echo "$filesize" | numfmt --to=iec 2>/dev/null)
    echo "git-mega:process the next file, ${sizestring}" >&2 #to avoid output to stdin
    myhash=$(git mega gethash $dstfile)
    if [ ! "$myhash" == "$fhash" ]; then #dstfile corrupted
       echo ${srcfile}
    fi
  else #not found in dstdir
    echo ${srcfile}
  fi
done
