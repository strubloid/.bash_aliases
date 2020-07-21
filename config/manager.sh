#!/bin/bash

## loading all variables
source config/variables.sh

## This will check what is the operational system loaded
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

## This will remove the temporary file
function removeTempFile()
{
   ## removing the old one if exist
    if [ -f ${TEMP_FILE} ]; then
        rm ${TEMP_FILE}
    fi
}

## This will check if a file exist
checkFileExists()
{
    if [[ -f  $1 ]]; then
        return 1
    else
        return 0
    fi
}

## Check if exist a string $1 inside of a file $2
checkStringExistIntoFile()
{
    EXISTLINE=$(grep -F "$1" $2 )
    if [[ ${EXISTLINE} ]]; then
        return 1
    else
        return 0
    fi
}

# Creation of the temp file that we will be using
# to build the new bash_alias
function createTempFile()
{
    # this folder will contain aliases that are common with all the OS
    generalFolder="./aliases/general"

    # this is the folder that will contain the actual OS specifications
    operationalSystemFolder="./aliases/$1"

    # list of files to load the content
    listOfFilesToUpdate=$(find ${generalFolder} ${operationalSystemFolder} -type f)

    for file in ${listOfFilesToUpdate}; do

        printf '## (Strubloid::Start) FILE: ' >> ${TEMP_FILE} && printf  $file >> ${TEMP_FILE} &&  printf '\n\n' >> ${TEMP_FILE};
        tail -n +2  ${file} >> ${TEMP_FILE}
        printf '\n## (Strubloid::End) ## FILE: ' >> ${TEMP_FILE} && printf  $file >> ${TEMP_FILE} &&  printf '\n\n' >> ${TEMP_FILE};

    done
}

## This will setup the bash aliases file
setupBashAliasFile()
{
  checkFileExists ${HOME_ALIASES}
  RETURN_CODE=$?

  ## checking if doesn't exist the file
  if [[ ${RETURN_CODE} -eq "0" ]]; then

    echo "[]: Creating the ~/.bash_alias file"
    touch ${HOME_ALIASES}

  else
    echo "[]: ~/.bash_alias already exists, moving on"
  fi
}

## This will setup the bash profile file
setupBashProfileFile()
{
  checkFileExists ${HOME_PROFILE}
  RETURN_CODE=$?

  ## checking if doesn't exist the file
  if [[ ${RETURN_CODE} -eq "0" ]]; then

    echo "[]: Creating the ~/.bash_profile file"
    touch ${HOME_PROFILE} && cp config/bash_profile ${HOME_PROFILE}

  else
    echo "[]: ~/.bash_profile already exists, moving on"
  fi
}

## This will setup the bash prompt file
setupBashPromptFile()
{
  checkFileExists ${HOME_PROMPT}
  RETURN_CODE=$?

  ## checking if doesn't exist the file
  if [[ ${RETURN_CODE} -eq "0" ]]; then

    echo "[]: Creating the ~/.bash_prompt file"
    touch ${HOME_PROMPT} && cp config/bash_prompt ${HOME_PROMPT}

  else
    echo "[]: ~/.bash_prompt already exists, moving on"
  fi
}

# This will update the terminal configurations
updateBashTerminal()
{
  if [ -f ${HOME_PROFILE} ]; then
    source ${HOME_PROFILE}
    echo "[]: updating terminal"
  else
    echo "[ERR]: missing file ~/.bash_profile"
  fi
}

## This will make sure that will exist on the ~/.bash_profile the lines:
##
## if [ -f ~/.bash_aliases ]; then
##    . ~/.bash_aliases
## fi
##
## if [ -f ~/.bash_prompt ]; then
##    . ~/.bash_prompt
## fi
checkIfExistBashPromptAndAlias() {

  ## checking if exist the ~/.bash_aliases into ~/.bash_profile
  checkStringExistIntoFile "~/.bash_aliases" ${HOME_PROFILE}
  EXIST_ALIAS=$?

  ## This will add if the result isnt on ~/.bash_profile
  if [[ ${EXIST_ALIAS} -eq "0" ]]; then
    printf "\n" >>${HOME_PROFILE} && echo "${BASH_ALIASES_LINE}" >>${HOME_PROFILE}
  fi

  ## checking if exist the ~/.bash_prompt into ~/.bash_profile
  checkStringExistIntoFile "~/.bash_prompt" ${HOME_PROFILE}
  EXIST_PROMPT=$?

  ## This will add if the result isnt on ~/.bash_profile
  if [[ ${EXIST_PROMPT} -eq "0" ]]; then
    printf "\n" >>${HOME_PROFILE} && echo "${BASH_PROMPT_LINE}" >>${HOME_PROFILE}
  fi
}

## Generation/replecament of the .bash_aliases file
generateBashAlias()
{
  echo "[]: Generating the ~/.bash_aliases file"

  # getting what is the operational system
  operationalSystem=$(getOperationalSystem);

  # removing the temp file bash_temp
  removeTempFile

  # this folder will contain aliases that are common with all the OS
  generalFolder="./aliases/general"

  # Creating the temp file bash_temp with all aliases
  createTempFile ${operationalSystem}

  # updating the file on the operational system
  cp ${TEMP_FILE} ${HOME_ALIASES}

  # removing the temp file bash_temp
  # removeTempFile

}
