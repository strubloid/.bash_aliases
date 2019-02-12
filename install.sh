#!/bin/bash

## loading the functions sh
source config/functions.sh

$(checkFileExists ${HOME_ALIASES})
RETURN_CODE=$?

## checking if doesn't exist the file
if [[ ${RETURN_CODE} -eq "0" ]]; then

    echo "[step 1]: Creating the ~/.bash_alias file"
    touch ${HOME_ALIASES}

else
    echo "[step 1]: already exists, moving on"
fi

## checking if exist the ~/.bash_aliases into ~/.bashrc
$(checkStringExistIntoFile "~/.bash_aliases" ${BASHRC})
RETURN_CODE=$?

## if we dont have it, we must create
if [[ ${RETURN_CODE} -eq "0" ]];
    then
        echo "[step 2]: It is missing ~/.bash_aliases line, creating now!"

        ## adding a new line to this file
        printf "\n" >> ${BASHRC}

        ## adding the configuration for the ~/.bash_aliases
        echo "${BASH_ALIASES_LINE}" >> ${BASHRC}
        
        ## update the ~./bashrc
        source ${BASHRC}

    else
        echo "[step 2]: already exists, moving on"

fi

echo "[Step 3]: Installation is finished"