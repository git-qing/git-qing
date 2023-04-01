#!/bin/bash
#
basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $basedir/libfuncs.sh
SetDirs
exit_if_not_qing

echo "git-qing is installed"
echo "checking the local qing space size..."
filesize=$(du -sh "$mainTreeTop/.qing" |cut -f1)
echo "$filesize"
