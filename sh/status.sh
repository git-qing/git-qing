#!/bin/bash
#
basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $basedir/libfuncs.sh
SetDirs
exit_if_not_mega

echo "git-mega is installed"
echo "checking the local mega space size..."
filesize=$(du -sh "$mainTreeTop/.mega" |cut -f1)
echo "$filesize"
