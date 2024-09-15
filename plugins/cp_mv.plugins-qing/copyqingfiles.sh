#!/bin/bash
# copy or move mega files
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

copy_or_move="move" #change copy to move if a moving is preferred
while read line; do
  echo "$copy_or_move $line ..."
  fhash=${line##*/}
  subdir=${fhash:0:2}
  dstfile=$dstdir/$subdir/$fhash
  if [ -e $dstfile ]; then #dstfile corrupted, otherwise it will not be in the list
    myhash=$(git mega gethash $dstfile)
    if [ "$myhash" != "$fhash" ]; then #confirm dstfile corrupted
      chmod +w $dstfile
      rm -rf $dstfile
    else
      continue #dstfile is good, go to next file
    fi
  fi
  mkdir -p $dstdir/$subdir
  if [[ "$copy_or_move" == "copy" ]]; then
    cp -rp $line $dstfile
  else
    mv $line $dstfile
  fi
  chmod a-w $dstfile #lock the file to avoid an accidental modification
done < $list
echo "$copy_or_move Done"

if [[ "$copy_or_move" == "move" ]]; then
  echo "all local mega files were moved into MIRROR:$MIRROR"
  echo "run 'git mega download' to connect local mega space with the MIRROR"
  git mega download
fi

exit 0
