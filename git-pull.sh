#!/bin/sh

usage()
{
    echo "Usage: $0 <directory>"
    exit -1
}

if [ $# -eq 0 ]
then
    usage
fi

while [ $# -gt 0 ]
do

    startDirectory=$1
    if [ ! -d $startDirectory ]
    then
        echo "Directory $startDirectory does not exist..."
    else
        if [ -d $startDirectory/.git ]
        then
	    echo "-------------------------------"
	    echo "-- Updating $startDirectory"
	    echo "-------------------------------"
            pushd $startDirectory >/dev/null
            git pull
            popd >/dev/null 
        else
	    echo "-----------------------------------------------------------------------"
	    echo "-- Recursively updating $startDirectory"
	    echo "-----------------------------------------------------------------------"
            echo pulling $startDirectory
            for directory in `ls -Al $startDirectory | grep ^d | awk '{printf("%s\n",$9);}'`
            do
                ./gitPull.sh $startDirectory/$directory
            done
        fi
    fi

    shift

done
