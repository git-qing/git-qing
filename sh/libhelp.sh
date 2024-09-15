#!/bin/bash
# git mega help
help_n_exit()
{
  mysection=$1
  echo "Usage:"
  if [[ "$mysection" == "all" ]] || [[ "$mysection" == "first" ]]; then
  cat <<EOF
  qit mega [help]
  git mega hello
  git mega install
  git mega deposit/withdraw <dir|file>
  git mega upload/download
  git mega gethash file
  git mega compareDirs src dest
  git mega verify <dir>
  git mega repair <dir>
  git mega allHandsCheck
  git mega uninstall

 1.show help information
 2.check whether the git-mega filter is installed for a clone
 3.install the git-mega filter for current clone and configure for current work copy
 4.deposit/withdraw mega files from the mega space,<dir> takes a relative path
 5.upload to/download from a MIRROR and/or remote service
 6.generate the file hash used by git-mega for a given file
 7.compare the mega files in two directories and show those in src but not in dest
 8.verify the integrity of mega files in the mega space
 9.repair broken links, <dir> takes a relative path
10.check whether all mega-file links in the working directory are valid
11.uninstall the git-mega filter

EOF
  fi

  if [[ "$mysection" == "gge" ]]; then
  cat <<EOF
  git mega uninstall

EOF
  fi

  exit 0
}
