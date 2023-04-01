#!/bin/bash
# clean filter, modify before staging 
#
basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $basedir/libfuncs.sh
SetDirs
exit_if_not_qing
mkdir -p "$tmpdir"

filepath="$@"
attr=$workTreeTop/.gitattributes
if [[ -e $attr ]] && $(grep 'qing.largefiles' $attr 1>/dev/null 2>&1) && $(QingOrNot $filepath) ; then
  qlink $filepath #return the relative link to a qing file
else
  echo "$(</dev/stdin)"
fi
