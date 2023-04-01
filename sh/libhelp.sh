#!/bin/bash
# git qing help
help_n_exit()
{
  mysection=$1
  echo "Usage:"
  if [[ "$mysection" == "all" ]] || [[ "$mysection" == "first" ]]; then
  cat <<EOF
  qit qing [help]
  git qing hello
  git qing install
  git qing deposit/withdraw <dir|file>
  git qing upload/download
  git qing gethash file
  git qing compareDirs src dest
  git qing verify <dir>
  git qing repair <dir>
  git qing allHandsCheck
  git qing uninstall

 1.show help information
 2.check whether the git-qing filter is installed for a clone
 3.install the git-qing filter for current clone and configure for current work copy
 4.deposit/withdraw qing files from the qing space,<dir> takes a relative path
 5.upload to/download from a MIRROR and/or remote service
 6.generate the file hash used by git-qing for a given file
 7.compare the qing files in two directories and show those in src but not in dest
 8.verify the integrity of qing files in the qing space
 9.repair broken links, <dir> takes a relative path
10.check whether all qing-file links in the working directory are valid
11.uninstall the git-qing filter

EOF
  fi

  if [[ "$mysection" == "gge" ]]; then
  cat <<EOF
  git qing uninstall

EOF
  fi

  exit 0
}
