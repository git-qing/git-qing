#!/bin/bash
# git-mega mirrors at different HPC platforms
#
if [[ -d /A/PATH/AT/PLATFORM1 ]] ; then
    PLATFORM=platfrom1
    MIRROR="/PATH/TO/MIRROR/DIR"
if [[ -d /A/PATH/AT/PLATFORM2 ]] ; then
    PLATFORM=platfrom2
else
    PLATFORM=unknow
    MIRROR="/this/is/an/unknow/platform"
    exit 1
fi
