#!/bin/bash
#  check whether all links in the working copy point to a valid qing file under the qing space
#
basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $basedir/libfuncs.sh
SetDirs
exit_if_not_qing

# find links pointing to an inaccessible qing file
echo "inaccessible qing files:"
find "$workTreeTop" -type l -print0 | while IFS= read -r -d '' myfile
do
  if [[ ! "$myfile" == *".git/"* ]] && [[ ! "$myfile" == *".qing/"* ]] && $(is_link_to_qing_space "$myfile"); then
    flink=$(readlink $myfile)
    fhash=${flink##*/}
    fname=$qroot/${fhash:0:2}/${fhash}
    if [[ ! -e $fname ]]; then
      #if dir existed but qing file not accessible, it means current MIRROR lacks this file as well
      echo ${fhash:0:2}/${fhash}
    fi
  fi
done
