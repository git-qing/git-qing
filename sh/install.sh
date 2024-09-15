#!/bin/bash
# install and configure git-mega
#  .mega needs to be outside of .git so that the removal of .git does not affect the .mega storage 
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
git config --replace-all filter.mega.clean 'git-mega --modifyBeforeStaging %f'

# 2. add the mega filter (.git/info/attributes)
ierr=`grep "^* filter=mega" $mainTreeTop/.git/info/attributes 1>/dev/null 2>/dev/null; echo $?`
if [[ $ierr -ne 0 ]]; then
  echo -e "\n#Add the mega filter. DO NOT REMOVE!\n* filter=mega\n" >> $mainTreeTop/.git/info/attributes
fi

# 3. set the pre-commit hook
if [ ! -f $mainTreeTop/.git/hooks/pre-commit ]; then
  echo -e "#!/bin/bash" > $mainTreeTop/.git/hooks/pre-commit
fi
chmod +x $mainTreeTop/.git/hooks/pre-commit
ierr=`grep "^git mega --preCommit" $mainTreeTop/.git/hooks/pre-commit 1>/dev/null 2>/dev/null; echo $?`
if [[ $ierr -ne 0 ]]; then
  echo -e "git mega --preCommit">>$mainTreeTop/.git/hooks/pre-commit
fi

#4. add .mega in .git/info/exclude if not there yet
ierr=`grep "^.mega" $mainTreeTop/.git/info/exclude 1>/dev/null 2>/dev/null; echo $?`
if [[ $ierr -ne 0 ]]; then
  echo -e "\n#ignore the .mega space. DO NOT REMOVE!\n.mega\n" >> $mainTreeTop/.git/info/exclude
fi

#5.set default large file filter rule in .gitattributes # only for current worktree
ierr=$(grep "^* mega.largefiles=(largerthan=.*kb)" $workTreeTop/.gitattributes 1>/dev/null 2>/dev/null; echo $?)
if [[ $ierr -ne 0 ]]; then
  echo -e "* mega.largefiles=(largerthan=600kb)" >> $workTreeTop/.gitattributes
fi

echo -e "The git-mega filter installed and the git-mega configuration for current HEAD:\n"
grep "mega.largefiles=" $workTreeTop/.gitattributes
echo -e "\
\nBy default, non-text files and files larger than 600kb will be handled by git-mega.\n\
run 'git mega' for help"
