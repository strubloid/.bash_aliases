#!/bin/bash

# Strubloid::linux::bash

search-biggest-files()
{
    if [ -z "$1" ]
    then
        echo "You must pass the folder that you will be checking";
        return 1
    fi

    if [ -z "$2" ]; then
        quantity=30
    else
        quantity=$2
    fi

    echo "This check the folder $1 a command: du -sh $1 | sort -rh | head -n${quantity}"
    sudo du -sh $1* | sort -rh | head -n${quantity}
}
