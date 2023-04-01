#!/bin/bash
# colloections of commom functions
# all non "local" variables are global and can be acessed by calling scripts
#
QING_SHA_CMD=${QING_SHA_CMD:-"shasum -a 512"}
QING_SHASTR_LEN="128" #64 for sha256sum and 128 for sha512sum

#find the workTreeTop, workGitDIR, mainTreeTop, tmpdir, qroot
# worktrees: .git/worktrees/PATH_NAME
function SetDirs {
  workTreeTop=$( git rev-parse --show-toplevel 2>/dev/null )
  if [ -f $workTreeTop/.git ]; then #if .git is a file, then current directory is a linked_worktree
    local workGitDir=$(cat $workTreeTop/.git)
    workGitDir=$(echo "${workGitDir#*:}" |xargs)
    mainTreeTop=${workGitDir%%/.git/worktrees*}
    tmpdir=$workGitDir/qing_tmp  #each worktree uses its own qing_tmp/
  else
    mainTreeTop=$workTreeTop
    tmpdir=$workTreeTop/.git/qing_tmp
  fi

  qroot=$mainTreeTop/.qing #different worktrees share one qing space
}

# chmod -R +w for all read-only directories under current worktree
#  GIT should not deal with read-only files/directories, otherwise
#  it will cause unexpected messy results when swithing between commits
chmod_w_dirs()
{
  for mydir in $(find $workTreeTop -type d -not -path '*/.git/*' -not -path '*/.qing/*' -ls|grep 'dr-x'|rev|cut -d ' ' -f1|rev|xargs); do
    chmod -R +w $mydir
  done
}

is_qing_installed()
{
  local qing_installed=true

  $(git config filter.qing.clean 1>/dev/null 2>&1) || qing_installed=false

  # check the qing filter (.git/info/attributes)
  ierr=`grep "^* filter=qing" $mainTreeTop/.git/info/attributes 1>/dev/null 2>/dev/null; echo $?`
  [[ $ierr -ne 0 ]] && qing_installed=false

  # check the pre-commit hook
  ierr=`grep "^git qing --preCommit" $mainTreeTop/.git/hooks/pre-commit 1>/dev/null 2>/dev/null; echo $?`
  [[ $ierr -ne 0 ]] && qing_installed=false

  echo $qing_installed
}

exit_if_not_qing()
{
  local installed=$(is_qing_installed)
  if ! $installed ; then
    echo "git-qing is NOT installed, run 'git qing install' to install"
    exit 1
  fi
}

# determine whether a string is a possible SHA512SUM
isSHA512SUM()
{
  local STR="$1"
  if [[ "$STR"  =~ ^[a-f0-9]+$ ]] && [[ ${#STR} -eq $QING_SHASTR_LEN ]]; then
    echo true
  else
    echo false
  fi
}

# Is $1 a link pointing to a qing file
is_link_to_qing_space()
{
  local mylink=$1
  if [[ -L $mylink ]]; then #only determin if it is a link, don't need it to be a valid link
    local lnfile=$(readlink $mylink ) 
    if [[ "${lnfile}" == *".qing/"* ]]; then
      lnfile=${lnfile##*/}
      if $(isSHA512SUM "$lnfile"); then
        echo true
      else
        echo false
      fi
    else
      echo false
    fi
  else
    echo false
  fi
}

#generate a relative link pointing to a qing file, for the clean filter
function qlink {
  local myfile=$1
  local myhash=$( ${QING_SHA_CMD} $myfile | cut -d ' ' -f1 )
  local subdir=${myhash:0:2}
  local destfile="$qroot"/"$subdir"/"$myhash"
  ln -rsnf "$destfile" "${myfile}_qingtmp" 2>/dev/null
  local lnfile=$(readlink ${myfile}_qingtmp )
  rm -rf ${myfile}_qingtmp
  echo $lnfile
}

# determine whether a file($1) should be put into the qing space
function QingOrNot {
  local filepath="$1"
  [ -d $filepath ] && return 1  #return 1 if it is a directory
  [ -L $filepath ] && return 1  #return 1 if it is a link
  local filetype=$(file $filepath)
  local file=${filepath##*/}
  local qattr=`git check-attr qing.largefiles $file` #qing.largefiles: (largerthan=600kb)
  if [[ "$qattr" == *unspecified* ]]; then # if not specified but qing-enabled, set to default value
    qattr="qing.largefiles: (largerthan=600kb)"
    echo ".gitattributes not found, installing a default one, done. $(git qing install &>/dev/null)" 1>&2
  fi
  qattr=$(echo "${qattr##*:}" | xargs) # xargs is to trim the string
  qattr=${qattr#*(}
  qattr=${qattr%)*}
  qing_it=false
  if [[ "$qattr" == "none" ]]; then
    qing_it=false
  elif [[ "$qattr" == "force" ]]; then
    qing_it=true
    filesize=$(du -b "$filepath" 2>/dev/null |cut -f1  2>/dev/null)
    if [ -z $filesize ]; then filesize=0; fi
  else  # check file type and file size
    qattr=${qattr#*=}
    qattr=${qattr%kb*}
    if [ -n "$qattr" ] && [ "$qattr" -eq "$qattr" ] 2>/dev/null; then #check if $qattr is a number
      qattr=$(( $qattr * 1024 )) #conver to bytes
      filesize=$(du -b "$filepath" 2>/dev/null |cut -f1  2>/dev/null)
      if [ -z $filesize ]; then filesize=0; fi
      if [[ "$filetype" != *text* && "$filetype" != *"symbolic link"* ]] || [[ $filesize -gt $qattr ]]; then #non-text or large files
        qing_it=true
      else
        qing_it=false
      fi
    else
      echo "bad qing.largefiles setting:$(git check-attr qing.largefiles $file)" 1>&2
      qing_it=false
    fi
  fi
  if $qing_it; then
    local sizestring=$(numfmt --to=iec $filesize 2>/dev/null)
    echo "git-qing:process '$filepath',${sizestring}" 1>&2
#  else
#    echo "git-qing:no action '$filepath'" 1>&2  #avoid unnessary messages
  fi
  echo $qing_it
}

# deposit a qing file into the qing space and lock it
deposit_if_qing_file()
{
  local myfile="$1"
  if $(QingOrNot "$myfile") ; then
    local myhash=$( ${QING_SHA_CMD} "$myfile" | cut -d ' ' -f1)
    if [ -z "$myhash" ]; then
      echo 'false'
      echo "cannot generate SHA512SUM for '$file'" 1>&2
    else
      local subdir=${myhash:0:2}
      local destfile="$qroot"/"$subdir"/"$myhash"
      mkdir -p "$qroot"/"$subdir" 2>/dev/null
      chmod +w "$destfile" 2>/dev/null
      mv -f "$myfile" "$destfile" 2>/dev/null #always trust new checksum-verified file
      chmod a-w "$destfile" #lock the qing file
      ln -rsnf "$destfile" "$myfile"
      echo 'true'
    fi
  else
    echo 'false'
  fi
}

source $basedir/libhelp.sh

