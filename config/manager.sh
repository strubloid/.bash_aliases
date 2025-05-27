#!/bin/bash

source $(pwd)/config/global/functions.sh
source $(pwd)/config/variables.sh
source $(pwd)/config/global/variables.sh

## This will check what is the operational system loaded
function getOperationalSystem() {
  case "$OSTYPE" in
  linux*) echo "linux" ;;
  darwin*) echo "mac" ;;
  win*) echo "windows" ;;
  msys*) echo "msys" ;;
  cygwin*) echo "cygwin" ;;
  bsd*) echo "bsd" ;;
  solaris*) echo "solaris" ;;
  *) echo "unknown" ;;
  esac
}

## This will remove the temporary file
function removeTempFile() {
  ## removing the old one if exist
  if [ -f ${BASH_TEMPORARY_F} ]; then
    rm ${BASH_TEMPORARY_F}
  fi
}

## This will check if a file exist
checkFileExists() {
  if [[ -f $1 ]]; then
    return 1
  else
    return 0
  fi
}

## This will check if a folder exist
checkFolderExists() {
  if [[ -d $1 ]]; then
    return 1
  else
    return 0
  fi
}


## Check if exist a string $1 inside of a file $2
checkStringExistIntoFile() {
  EXISTLINE=$(grep -F "$1" $2)
  if [[ ${EXISTLINE} ]]; then
    return 1
  else
    return 0
  fi
}

# Creation of the temp file that we will be using
# to build the new bash_alias
function createTempFile() {
  # this folder will contain aliases that are common with all the OS
  generalFolder="./aliases/general"

  # this is the folder that will contain the actual OS specifications
  operationalSystemFolder="./aliases/$1"

  # list of files to load the content
  listOfFilesToUpdate=$(find ${generalFolder} ${operationalSystemFolder} -type f ! -iname '*.swp')

  for file in ${listOfFilesToUpdate}; do

    printf '## (Strubloid::Start) FILE: ' >>${BASH_TEMPORARY_F} && printf $file >>${BASH_TEMPORARY_F} && printf '\n\n' >>${BASH_TEMPORARY_F}
    tail -n +2 ${file} >>${BASH_TEMPORARY_F}
    printf '\n## (Strubloid::End) ## FILE: ' >>${BASH_TEMPORARY_F} && printf $file >>${BASH_TEMPORARY_F} && printf '\n\n' >>${BASH_TEMPORARY_F}

  done
}

## This will setup the bash aliases file
setupBashAliasFile() {
  echoHeader "[Setup Bash Alias File]: "

  checkFileExists ${HOME_ALIASES}
  RETURN_CODE=$?

  ## checking if doesn't exist the file
  if [[ ${RETURN_CODE} -eq "0" ]]; then

    echoLine "[]: Creating the ~/.bash_alias file"
    touch ${HOME_ALIASES}

  else
    echoLine "[]: ~/.bash_alias already exists, moving on"
  fi
}

## This will setup the bash profile file
setupBashProfileFile() {
  echoHeader "[Setup Bash Profile File]: "

  checkFileExists ${HOME_PROFILE}
  RETURN_CODE=$?

  ## checking if doesn't exist the file
  if [[ ${RETURN_CODE} -eq "0" ]]; then

    echoLine "[]: Creating the ~/.bash_profile file"
    touch ${HOME_PROFILE} && cp $BASH_ALIASES_PROJECT_FOLDER/config/bash_profile ${HOME_PROFILE}

  else
    echoLine "[]: ~/.bash_profile already exists, moving on"
  fi

}


## This will setup the bash profile file
setupBashVariablesFile() {
  echoHeader "[Setup Bash Variables File]: "

  checkFileExists ${HOME_VARIABLES}
  RETURN_CODE=$?

  ## checking if doesn't exist the file
  if [[ ${RETURN_CODE} -eq "0" ]]; then

    echoLine "[]: Creating the ~/.bash_profile file"
    touch ${HOME_VARIABLES} && cp $BASH_ALIASES_PROJECT_FOLDER/config/bash_variables ${HOME_PROFILE}

  else
    echoLine "[]: ~/.bash_profile already exists, moving on"
  fi

}

## This will setup the bash prompt file
setupBashPromptFile() {
  echoHeader "[Setup Bash Prompt File]: $HOME_PROMPT"

  checkFileExists ${HOME_PROMPT}
  RETURN_CODE=$?

  ## checking if doesn't exist the file
  if [[ ${RETURN_CODE} -eq "0" ]]; then

    echoLine "[]: Creating the ~/.bash_prompt file"
    echoLine "[]: copying $BASH_ALIASES_PROJECT_FOLDER/config/bash_prompt"
    echoLine "[]: to $HOME_PROMPT"

    touch ${HOME_PROMPT} && cp $BASH_ALIASES_PROJECT_FOLDER/config/bash_prompt ${HOME_PROMPT}

  else
    echoLine "[]: ~/.bash_prompt already exists, moving on"
  fi
}

# This will update the terminal configurations
updateBashTerminal() {
  echoHeader "[Update Bash Terminal]: "

  ## Checking the operational system
  OS=$(getOperationalSystem)

  if [ "$OS" = "mac" ]; then
    if [ -f ~/.zshrc ]; then
      source ~/.zshrc
      echoLine "[]: updating terminal ~/.zshrc"
    else
      echoLine "[ERR]: missing file ~/.zshrc"
    fi
  else
    if [ -f "${HOME_PROFILE}" ]; then
      source "${HOME_PROFILE}"
      echoLine "[]: updating terminal ${HOME_PROFILE}"
    else
      echoLine "[ERR]: missing file ${HOME_PROFILE}"
    fi
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
upgradeElementsOnBashProfile() {
  echoHeader "[Upgrade Elements On Bash Profile]: "

  ## checking if exist the ~/.bash_g into ~/.bash_profile
  checkStringExistIntoFile "~/.bash_global" ${HOME_PROFILE}
  EXIST_GLOBAL=$?

  ## This will add if the result isn't on ~/.bash_profile
  if [[ ${EXIST_GLOBAL} -eq "0" ]]; then
    printf "\n" >>${HOME_PROFILE} && echo "${BASH_GLOBAL_LINE}" >>${HOME_PROFILE}
  else
    echoLine "[]: ~/.bash_global already exists, moving on"
  fi

  ## checking if exist the ~/.bash_aliases into ~/.bash_profile
  checkStringExistIntoFile "~/.bash_variables" ${HOME_PROFILE}
  EXIST_VARIABLES=$?

  ## This will add if the result isn't on ~/.bash_profile
  if [[ ${EXIST_VARIABLES} -eq "0" ]]; then
    printf "\n" >>${HOME_PROFILE} && echo "${BASH_VARIABLES_LINE}" >>${HOME_PROFILE}
  else
    echoLine "[]: ~/.bash_variables already exists, moving on"
  fi

  ## checking if exist the ~/.bash_aliases into ~/.bash_profile
  checkStringExistIntoFile "~/.bash_aliases" ${HOME_PROFILE}
  EXIST_ALIAS=$?

  ## This will add if the result isn't on ~/.bash_profile
  if [[ ${EXIST_ALIAS} -eq "0" ]]; then
    printf "\n" >>${HOME_PROFILE} && echo "${BASH_ALIASES_LINE}" >>${HOME_PROFILE}
  else
    echoLine "[]: ~/.bash_aliases already exists, moving on"
  fi

  ## checking if exist the ~/.bash_prompt into ~/.bash_profile
  checkStringExistIntoFile "~/.bash_prompt" ${HOME_PROFILE}
  EXIST_PROMPT=$?

  ## This will add if the result isn't on ~/.bash_profile
  if [[ ${EXIST_PROMPT} -eq "0" ]]; then
    printf "\n" >>${HOME_PROFILE} && echo "${BASH_PROMPT_LINE}" >>${HOME_PROFILE}
  else
    echoLine "[]: ~/.bash_prompt already exists, moving on"
  fi

    ## checking if exist the ~/.bash_prompt into ~/.bash_profile
  checkStringExistIntoFile "~/.git-completion.bash" ${HOME_PROFILE}
  EXIST_GIT_COMPLETION=$?

  ## This will add if the result isnt on ~/.bash_profile
  if [[ ${EXIST_GIT_COMPLETION} -eq "0" ]]; then
    printf "\n" >>${HOME_PROFILE} && echo "${GIT_COMPLETION_LINE}" >>${HOME_PROFILE}
  fi

  gitCompletion=~/.git-completion.bash
  if [ ! -f "$gitCompletion" ]; then
    curl "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash" -o ~/.git-completion.bash
  else
    echoLine "[]: ~/.git-completeon already exists, moving on"
  fi

# fix the mac version of it
#  operationalSystem=$(getOperationalSystem)
#
#  printf $operationalSystem;
#  if [ ${operationalSysrtem} != "mac"  ]; then
#    ## checking if exist the ~/.bash_prompt into ~/.bash_profile
#      checkStringExistIntoFile "~/.git-completion.bash" ${HOME_PROFILE}
#      EXIST_GIT_COMPLETION=$?
#
#      ## This will add if the result isnt on ~/.bash_profile
#      if [[ ${EXIST_GIT_COMPLETION} -eq "0" ]]; then
#        printf "\n" >>${HOME_PROFILE} && echo "${GIT_COMPLETION_LINE}" >>${HOME_PROFILE}
#      fi
#
#      gitCompletion=~/.git-completion.bash
#      if [ ! -f "$gitCompletion" ]; then
#        curl "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash" -o ~/.git-completion.bash
#      else
#        echoLine "[]: ~/.git-completeon already exists, moving on"
#      fi
#  fi

}

## Generation/replecament of the .bash_aliases file
generateBashAlias() {
  echoHeader "[Generate Bash Alias]: "

  # getting what is the operational system
  operationalSystem=$(getOperationalSystem)

  # removing the temp file bash_temp
  removeTempFile

  # this folder will contain aliases that are common with all the OS
  generalFolder="./aliases/general"

  # Creating the temp file bash_temp with all aliases
  createTempFile ${operationalSystem}

  # updating the file on the operational system
  cp ${BASH_TEMPORARY_F} ${HOME_ALIASES}
  echoLine "[]: creating $HOME/.bash_aliases"

  # removing the temp file bash_temp
  removeTempFile
  echoLine "[]: remove temp file ${BASH_TEMPORARY_F}"
}

# This will set the environment variable for this folder
setupEnvironmentVariable() {
  echoHeader "[Setup Environment Variables]: "

  # checking if exist the line already
  checkStringExistIntoFile "BASH_ALIASES_PROJECT_FOLDER" ${HOME_VARIABLES}
  EXIST_BASH_ALIASES_PROJECT_FOLDER=$?

  ## This will add if the result isnt on ~/.bash_profile
  if [[ ${EXIST_BASH_ALIASES_PROJECT_FOLDER} -eq "0" ]]; then
    printf "\n" >>${HOME_PROFILE} && \
    echo "export BASH_ALIASES_PROJECT_FOLDER=$(pwd)" >> ${HOME_VARIABLES}
  else
    echoLine "[]: BASH_ALIASES_PROJECT_FOLDER already exists, moving on"
  fi

}

## this will move the scripts from scripts folder to the correct
## .bash_aliases_scripts
moveScripts(){

    echoHeader "[Move Scripts]:"

    checkFolderExists "$BASH_ALIASES_SCRIPTS"
    RETURN_CODE=$?

    ## checking if folder doesn't exist
    printf "  []: Exist Folder? "
    if [[ ${RETURN_CODE} -eq "0" ]]; then
      printf "No, creating a new one\n"
      mkdir -p "$BASH_ALIASES_SCRIPTS"
    else
      printf "Yes\n"
    fi

    ## loading the scripts folder
    BASH_PROJECT_SCRIPS_LOCAL="$BASH_ALIASES_PROJECT_FOLDER/scripts"

    echoLine "[]: Copying"
    echoLine "=> From: $BASH_PROJECT_SCRIPS_LOCAL"
    echoLine "=> To: $BASH_ALIASES_SCRIPTS"
    cp $BASH_ALIASES_PROJECT_FOLDER/scripts/* $BASH_ALIASES_SCRIPTS

}