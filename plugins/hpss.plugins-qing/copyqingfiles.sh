#!/bin/bash
# copy qing files
#
if [ $# -lt 3 ]; then
  echo "not enough paramaters"
  exit 1
fi

list=$1
srcdir=$2
dstdir=$3

mkdir -p $dstdir # if dstdir not existed, create one to avoid trivial errors
if [[ ! -e $list ]] || [[ ! -d $srcdir ]] || [[ ! -d $dstdir  ]]; then
  echo "wrong parameters"
  exit 1
fi

while read line; do
  echo "copy $line ..."
  fhash=${line##*/}
  subdir=${fhash:0:2}
  dstfile=$dstdir/$subdir/$fhash
  if [ -e $dstfile ]; then #dstfile corrupted, otherwise it will not be in the list
    myhash=$(git qing gethash $dstfile)
    if [ "$myhash" != "$fhash" ]; then #confirm dstfile corrupted
      chmod +w $dstfile
      rm -rf $dstfile
    else
      continue #dstfile is good, go to next file
    fi
  fi
  mkdir -p $dstdir/$subdir
  cp -rp $line $dstfile
  chmod a-w $dstfile #lock the file to avoid an accidental modification
done < $list

echo 'Done'
exit 0
