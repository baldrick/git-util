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
        echo "Directory $startDirectory does not exist - skipping..."
    else
        if [ -d $startDirectory/.git ]
        then
	    echo "----------------------------------------"
	    echo "-- git pull $startDirectory"
	    echo "----------------------------------------"
            pushd $startDirectory >/dev/null
            git pull
            popd >/dev/null 
        else
	    echo "-----------------------------------------------------------------------"
	    echo "-- Recursively updating $startDirectory"
	    echo "-----------------------------------------------------------------------"
            for directory in `ls -Al $startDirectory | grep ^d | awk '{printf("%s\n",$9);}'`
            do
	        # Use $0 so this script works if git-pull.sh isn't in your path...
		# Nice side-effect is that it also works if the script is renamed ;-)
                $0 $startDirectory/$directory
            done
        fi
    fi

    shift

done
