#!/bin/bash
# clean filter, modify before staging 
#
basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $basedir/libfuncs.sh
SetDirs
exit_if_not_mega
mkdir -p "$tmpdir"

filepath="$@"
attr=$workTreeTop/.gitattributes
if [[ -e $attr ]] && $(grep 'mega.largefiles' $attr 1>/dev/null 2>&1) && $(MegaOrNot $filepath) ; then
  qlink $filepath #return the relative link to a mega file
else
  echo "$(</dev/stdin)"
fi
