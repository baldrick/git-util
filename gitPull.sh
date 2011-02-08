#!/bin/sh

startDirectory=$1
if [ -d $startDirectory/.git ]
then
    pushd $startDirectory
    git pull
    popd
else
    echo pulling $startDirectory
    for directory in `ls -Al $startDirectory | grep ^d | awk '{printf("%s\n",$9);}'`
    do
        ./gitPull.sh $startDirectory/$directory
    done
fi
