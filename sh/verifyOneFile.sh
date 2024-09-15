#!/bin/bash
#
basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $basedir/libfuncs.sh
SetDirs
#
myfile="$1"
filename="${myfile##*/}"
#
#check if filename is a SHA512SUM, if not, exit
fname_hashed=$(isSHA512SUM "$filename")
if ! $fname_hashed; then
  echo "'$filename', file name not an sha512sum hash string"
  exit 1
fi
#
filesize=$(du -b "$myfile" 2>/dev/null |cut -f1  2>/dev/null)
sizestring=$(numfmt --to=iec $filesize 2>/dev/null)
echo "git-mega:process the next file,${sizestring}" 1>&2 #this only goes to stderr
myhash=`${MEGA_SHA_CMD} $myfile | cut -d ' ' -f1`
subdir=${myhash:0:2}
if [[ "$myhash" != "$filename" ]]; then
  echo "git-mega:verify '$filename'...corrupted"
else
  echo "git-mega:verify '$filename'...good"
fi
