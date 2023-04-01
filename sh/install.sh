#!/bin/bash
# install and configure git-qing
#  .qing needs to be outside of .git so that the removal of .git does not affect the .qing storage 
#
basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $basedir/libfuncs.sh
SetDirs
if ! $(git rev-parse --is-inside-work-tree &>/dev/null); then
  echo "fatal: not a git repository "
  exit 1
fi

mkdir -p $qroot
mkdir -p $tmpdir

# 1. add the clean filter method
git config --replace-all filter.qing.clean 'git-qing --modifyBeforeStaging %f'

# 2. add the qing filter (.git/info/attributes)
ierr=`grep "^* filter=qing" $mainTreeTop/.git/info/attributes 1>/dev/null 2>/dev/null; echo $?`
if [[ $ierr -ne 0 ]]; then
  echo -e "\n#Add the qing filter. DO NOT REMOVE!\n* filter=qing\n" >> $mainTreeTop/.git/info/attributes
fi

# 3. set the pre-commit hook
if [ ! -f $mainTreeTop/.git/hooks/pre-commit ]; then
  echo -e "#!/bin/bash" > $mainTreeTop/.git/hooks/pre-commit
fi
chmod +x $mainTreeTop/.git/hooks/pre-commit
ierr=`grep "^git qing --preCommit" $mainTreeTop/.git/hooks/pre-commit 1>/dev/null 2>/dev/null; echo $?`
if [[ $ierr -ne 0 ]]; then
  echo -e "git qing --preCommit">>$mainTreeTop/.git/hooks/pre-commit
fi

#4. add .qing in .git/info/exclude if not there yet
ierr=`grep "^.qing" $mainTreeTop/.git/info/exclude 1>/dev/null 2>/dev/null; echo $?`
if [[ $ierr -ne 0 ]]; then
  echo -e "\n#ignore the .qing space. DO NOT REMOVE!\n.qing\n" >> $mainTreeTop/.git/info/exclude
fi

#5.set default large file filter rule in .gitattributes # only for current worktree
ierr=$(grep "^* qing.largefiles=(largerthan=.*kb)" $workTreeTop/.gitattributes 1>/dev/null 2>/dev/null; echo $?)
if [[ $ierr -ne 0 ]]; then
  echo -e "* qing.largefiles=(largerthan=600kb)" >> $workTreeTop/.gitattributes
fi

echo -e "The git-qing filter installed and the git-qing configuration for current HEAD:\n"
grep "qing.largefiles=" $workTreeTop/.gitattributes
echo -e "\
\nBy default, non-text files and files larger than 600kb will be handled by git-qing.\n\
run 'git qing' for help"
