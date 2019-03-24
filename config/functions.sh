#!/bin/bash

## loading all variables
source config/variables.sh

checkFileExists()
{
    if [[ -f  $1 ]]; then
        return 1
    else
        return 0
    fi
}

checkStringExistIntoFile()
{
    EXISTLINE=$(grep -F "$1" $2 )
    if [[ ${EXISTLINE} ]]; then
        return 1
    else
        return 0
    fi

}

#operationalSystem()
#{
#    OS=`lowercase \`uname\``
#    echo ${OS}/
#}

lowercase(){
    echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}



