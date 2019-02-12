#!/bin/bash

## loading the functions sh
source config/functions.sh

ALIAS_FOLDER="./aliases/$(operationalSystem)"

echo "[Step 1] Loading Alias folder ${ALIAS_FOLDER}"

## loading all files inside of our root folder
FILESTOUPDATE=$(find ${ALIAS_FOLDER} -type f)

# removing the old one if exist
if [ -f ${EXPORTEDFILE} ]; then
    rm ${EXPORTEDFILE}
fi
# creating the export file
echo -n > ${EXPORTEDFILE};

## looping though the aliases folder
for file in ${FILESTOUPDATE}; do

    cat ${file} >> ${EXPORTEDFILE} && printf '\n' >> ${EXPORTEDFILE}

done

echo "[Step 2] Copying ${EXPORTEDFILE} to ${HOME_ALIASES}"
cp ${EXPORTEDFILE} ${HOME_ALIASES}

echo "[Step 3] Updating the ${BASHRC}"

#`source ${BASHRC}`
exec bash

echo "Upgrade successful"