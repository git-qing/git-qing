#!/bin/bash
#
basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $basedir/libfuncs.sh

echo "Version: $(cat $basedir/../VERSION)"
help_n_exit "all"
