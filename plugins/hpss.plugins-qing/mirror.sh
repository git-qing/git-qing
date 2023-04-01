#!/bin/bash
# git-qing mirrors at different HPC platforms
#
HPSS_DIR="/PATH/TO/HPSS/DIR"

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
