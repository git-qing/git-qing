#!/bin/bash
#
basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $basedir/libfuncs.sh
SetDirs #mainTreeTop, workTreeTop, tmpdir, qroot

if $(is_qing_installed); then
  echo "Hello, git-qing is installed"
else
  echo "Hello, git-qing is NOT installed, run 'git qing install' to install"
fi
chmod_w_dirs
