#!/bin/bash
#
basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $basedir/libfuncs.sh
SetDirs
exit_if_not_mega
mkdir -p "$tmpdir"

# remove the clean filter methods
git config --unset filter.mega.clean

# remove the mega filter (.git/info/attributes)
ierr=$(grep -v "^* filter=mega" $mainTreeTop/.git/info/attributes >$tmpdir/uninstall.tmp 2>/dev/null; echo $?)
if [[ $ierr -eq 0 ]]; then
  cp $tmpdir/uninstall.tmp $mainTreeTop/.git/info/attributes
fi

# remove the pre-commit hook
ierr=$(grep -v "^git mega" $mainTreeTop/.git/hooks/pre-commit >$tmpdir/uninstall.tmp 2>/dev/null; echo $?)
if [[ $ierr -eq 0 ]]; then
  cp $tmpdir/uninstall.tmp  $mainTreeTop/.git/hooks/pre-commit
fi

#remove .mega from .git/info/exclude
ierr=`grep -v "^.mega" $mainTreeTop/.git/info/exclude >$tmpdir/uninstallm.tmp 2>/dev/null; echo $?`
if [[ $ierr -eq 0 ]]; then
  cp $tmpdir/uninstall.tmp  $mainTreeTop/.git/info/exclude
fi

#
#echo "Users need to manually remove the 'mega.largefiles' settings in .gitattributes but it is okay to leave them there."
#
echo -e "The git-mega filter uninstalled"
echo -e "It is up to users to decide how to deal with .gitattributes and .mega/"
