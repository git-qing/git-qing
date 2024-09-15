#!/bin/bash
# colloections of commom functions
# all non "local" variables are global and can be acessed by calling scripts
#
MEGA_SHA_CMD=${MEGA_SHA_CMD:-"shasum -a 512"}
MEGA_SHASTR_LEN="128" #64 for sha256sum and 128 for sha512sum

#find the workTreeTop, workGitDIR, mainTreeTop, tmpdir, qroot
# worktrees: .git/worktrees/PATH_NAME
function SetDirs {
  workTreeTop=$( git rev-parse --show-toplevel 2>/dev/null )
  if [ -f $workTreeTop/.git ]; then #if .git is a file, then current directory is a linked_worktree
    local workGitDir=$(cat $workTreeTop/.git)
    workGitDir=$(echo "${workGitDir#*:}" |xargs)
    mainTreeTop=${workGitDir%%/.git/worktrees*}
    tmpdir=$workGitDir/mega_tmp  #each worktree uses its own mega_tmp/
  else
    mainTreeTop=$workTreeTop
    tmpdir=$workTreeTop/.git/mega_tmp
  fi

  qroot=$mainTreeTop/.mega #different worktrees share one mega space
}

# chmod -R +w for all read-only directories under current worktree
#  GIT should not deal with read-only files/directories, otherwise
#  it will cause unexpected messy results when swithing between commits
chmod_w_dirs()
{
  for mydir in $(find $workTreeTop -type d -not -path '*/.git/*' -not -path '*/.mega/*' -ls|grep 'dr-x'|rev|cut -d ' ' -f1|rev|xargs); do
    chmod -R +w $mydir
  done
}

is_mega_installed()
{
  local mega_installed=true

  $(git config filter.mega.clean 1>/dev/null 2>&1) || mega_installed=false

  # check the mega filter (.git/info/attributes)
  ierr=`grep "^* filter=mega" $mainTreeTop/.git/info/attributes 1>/dev/null 2>/dev/null; echo $?`
  [[ $ierr -ne 0 ]] && mega_installed=false

  # check the pre-commit hook
  ierr=`grep "^git mega --preCommit" $mainTreeTop/.git/hooks/pre-commit 1>/dev/null 2>/dev/null; echo $?`
  [[ $ierr -ne 0 ]] && mega_installed=false

  echo $mega_installed
}

exit_if_not_mega()
{
  local installed=$(is_mega_installed)
  if ! $installed ; then
    echo "git-mega is NOT installed, run 'git mega install' to install"
    exit 1
  fi
}

# determine whether a string is a possible SHA512SUM
isSHA512SUM()
{
  local STR="$1"
  if [[ "$STR"  =~ ^[a-f0-9]+$ ]] && [[ ${#STR} -eq $MEGA_SHASTR_LEN ]]; then
    echo true
  else
    echo false
  fi
}

# Is $1 a link pointing to a mega file
is_link_to_mega_space()
{
  local mylink=$1
  if [[ -L $mylink ]]; then #only determin if it is a link, don't need it to be a valid link
    local lnfile=$(readlink $mylink ) 
    if [[ "${lnfile}" == *".mega/"* ]]; then
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

#generate a relative link pointing to a mega file, for the clean filter
function qlink {
  local myfile=$1
  local myhash=$( ${MEGA_SHA_CMD} $myfile | cut -d ' ' -f1 )
  local subdir=${myhash:0:2}
  local destfile="$qroot"/"$subdir"/"$myhash"
  ln -rsnf "$destfile" "${myfile}_megatmp" 2>/dev/null
  local lnfile=$(readlink ${myfile}_megatmp )
  rm -rf ${myfile}_megatmp
  echo $lnfile
}

# determine whether a file($1) should be put into the mega space
function MegaOrNot {
  local filepath="$1"
  [ -d $filepath ] && return 1  #return 1 if it is a directory
  [ -L $filepath ] && return 1  #return 1 if it is a link
  local filetype=$(file $filepath)
  local file=${filepath##*/}
  local qattr=`git check-attr mega.largefiles $file` #mega.largefiles: (largerthan=600kb)
  if [[ "$qattr" == *unspecified* ]]; then # if not specified but mega-enabled, set to default value
    qattr="mega.largefiles: (largerthan=600kb)"
    echo ".gitattributes not found, installing a default one, done. $(git mega install &>/dev/null)" 1>&2
  fi
  qattr=$(echo "${qattr##*:}" | xargs) # xargs is to trim the string
  qattr=${qattr#*(}
  qattr=${qattr%)*}
  mega_it=false
  if [[ "$qattr" == "none" ]]; then
    mega_it=false
  elif [[ "$qattr" == "force" ]]; then
    mega_it=true
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
        mega_it=true
      else
        mega_it=false
      fi
    else
      echo "bad mega.largefiles setting:$(git check-attr mega.largefiles $file)" 1>&2
      mega_it=false
    fi
  fi
  if $mega_it; then
    local sizestring=$(numfmt --to=iec $filesize 2>/dev/null)
    echo "git-mega:process '$filepath',${sizestring}" 1>&2
#  else
#    echo "git-mega:no action '$filepath'" 1>&2  #avoid unnessary messages
  fi
  echo $mega_it
}

# deposit a mega file into the mega space and lock it
deposit_if_mega_file()
{
  local myfile="$1"
  if $(MegaOrNot "$myfile") ; then
    local myhash=$( ${MEGA_SHA_CMD} "$myfile" | cut -d ' ' -f1)
    if [ -z "$myhash" ]; then
      echo 'false'
      echo "cannot generate SHA512SUM for '$file'" 1>&2
    else
      local subdir=${myhash:0:2}
      local destfile="$qroot"/"$subdir"/"$myhash"
      mkdir -p "$qroot"/"$subdir" 2>/dev/null
      chmod +w "$destfile" 2>/dev/null
      mv -f "$myfile" "$destfile" 2>/dev/null #always trust new checksum-verified file
      chmod a-w "$destfile" #lock the mega file
      ln -rsnf "$destfile" "$myfile"
      echo 'true'
    fi
  else
    echo 'false'
  fi
}

source $basedir/libhelp.sh

