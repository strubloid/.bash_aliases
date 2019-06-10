#!/bin/bash

source config/variables.sh

function getOperationalSystem()
{
    case "$OSTYPE" in
      linux*)   echo "linux" ;;
      darwin*)  echo "mac" ;;
      win*)     echo "windows" ;;
      msys*)    echo "msys" ;;
      cygwin*)  echo "cygwin" ;;
      bsd*)     echo "bsd" ;;
      solaris*) echo "solaris" ;;
      *)        echo "unknown" ;;
    esac
}

function removeBashAliasExportedFile()
{
   ## removing the old one if exist
    if [ -f ${EXPORTEDFILE} ]; then
        rm ${EXPORTEDFILE}
    fi
}

function createBashAliasExportedFile()
{
    echo -n > ${EXPORTEDFILE};
}

function createBashAliasExportedFile()
{
    # this folder will contain aliases that are common with all the OS
    generalFolder="./aliases/general"

    # this is the folder that will contain the actual OS specifications
    operationalSystemFolder="./aliases/$1"


    # list of files to load the content
    listOfFilesToUpdate=$(find ${generalFolder} ${operationalSystemFolder} -type f)


#    for file in "`find ${generalFolder} ${operationalSystemFolder} -type f`"; do
    for file in ${listOfFilesToUpdate}; do

        printf '## (Start) ## FILE: ' >> ${EXPORTEDFILE} && printf  $file >> ${EXPORTEDFILE} &&  printf '\n\n' >> ${EXPORTEDFILE};
        cat ${file} >> ${EXPORTEDFILE}
        printf '\n## (End) ## FILE: ' >> ${EXPORTEDFILE} && printf  $file >> ${EXPORTEDFILE} &&  printf '\n\n' >> ${EXPORTEDFILE};

    done
}