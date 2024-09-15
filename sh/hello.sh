#!/bin/bash
#
basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $basedir/libfuncs.sh
SetDirs #mainTreeTop, workTreeTop, tmpdir, qroot

if $(is_mega_installed); then
  echo "Hello, git-mega is installed"
else
  echo "Hello, git-mega is NOT installed, run 'git mega install' to install"
fi
chmod_w_dirs
