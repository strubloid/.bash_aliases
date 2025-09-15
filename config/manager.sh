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
  # Create a temporary file
  rm -f ${BASH_TEMPORARY_F}
  touch ${BASH_TEMPORARY_F}
  
  # Use absolute paths based on BASH_ALIASES_PROJECT_FOLDER
  # this folder will contain aliases that are common with all the OS
  generalFolder="$BASH_ALIASES_PROJECT_FOLDER/aliases/general"

  # this is the folder that will contain the actual OS specifications
  operationalSystemFolder="$BASH_ALIASES_PROJECT_FOLDER/aliases/$1"

  # list of files to load the content
  listOfFilesToUpdate=$(find ${generalFolder} ${operationalSystemFolder} -type f -name "*.sh" ! -iname '*.swp' 2>/dev/null)

  if [ -z "$listOfFilesToUpdate" ]; then
    echoLine "[WARN]: No alias files found in $generalFolder or $operationalSystemFolder"
    # Create an empty temporary file to avoid errors
    echo "# No aliases found" > ${BASH_TEMPORARY_F}
    return
  fi

  # Create a header for the file
  echo "# Generated bash aliases by strubloid's bash_aliases project" > ${BASH_TEMPORARY_F}
  echo "# $(date)" >> ${BASH_TEMPORARY_F}
  echo "" >> ${BASH_TEMPORARY_F}

  for file in ${listOfFilesToUpdate}; do
    # Add a comment with the source file path
    echo "# Source from: $file" >> ${BASH_TEMPORARY_F}
    
    # Check if file is readable
    if [ -r "$file" ]; then
      # Skip the first line (shebang) if it exists and append the rest
      awk '
        BEGIN { skip_first = 0; }
        /^#!/ && NR == 1 { skip_first = 1; next; }
        { print; }
      ' "$file" >> ${BASH_TEMPORARY_F}
      
      # Add a separator
      echo "" >> ${BASH_TEMPORARY_F}
      echo "# End of $file" >> ${BASH_TEMPORARY_F}
      echo "" >> ${BASH_TEMPORARY_F}
    else
      echo "# Error: Could not read file $file" >> ${BASH_TEMPORARY_F}
      echo "" >> ${BASH_TEMPORARY_F}
    fi
  done
}

## This will setup the bash aliases file
setupBashAliasFile() {
  echoHeader "[Setup Bash Alias File]: "

  checkFileExists ${HOME_ALIASES}
  RETURN_CODE=$?

  ## checking if doesn't exist the file
  if [[ ${RETURN_CODE} -eq "0" ]]; then

    echoLine "* Creating the ~/.bash_alias file"
    touch ${HOME_ALIASES}

  else
    echoLine "* ~/.bash_alias already exists, moving on"
  fi
}

## This will setup the bash profile file
setupBashProfileFile() {
  echoHeader "[Setup Bash Profile File]: "

  checkFileExists ${HOME_PROFILE}
  RETURN_CODE=$?

  ## checking if doesn't exist the file
  if [[ ${RETURN_CODE} -eq "0" ]]; then

    echoLine "* Creating the ~/.bash_profile file"
    touch ${HOME_PROFILE} && cp $BASH_ALIASES_PROJECT_FOLDER/config/bash_profile ${HOME_PROFILE}

  else
    echoLine "* ~/.bash_profile already exists, moving on"
  fi

}


## This will setup the bash profile file
setupBashVariablesFile() {
  echoHeader "[Setup Bash Variables File]: "

  checkFileExists ${HOME_VARIABLES}
  RETURN_CODE=$?

  ## checking if doesn't exist the file
  if [[ ${RETURN_CODE} -eq "0" ]]; then

    echoLine "* Creating the ~/.bash_profile file"
    touch ${HOME_VARIABLES} && cp $BASH_ALIASES_PROJECT_FOLDER/config/bash_variables ${HOME_PROFILE}

  else
    echoLine "* ~/.bash_profile already exists, moving on"
  fi

}

## This will setup the bash prompt file
setupBashPromptFile() {
  echoHeader "[Setup Bash Prompt File]: $HOME_PROMPT"

  checkFileExists ${HOME_PROMPT}
  RETURN_CODE=$?

  ## checking if doesn't exist the file
  if [[ ${RETURN_CODE} -eq "0" ]]; then
    # Get OS and shell info
    OS=$(getOperationalSystem)
    
    if [ "$OS" = "mac" ] && [ "$SHELL" = "/bin/zsh" -o -n "$ZSH_VERSION" ]; then
      # For macOS with zsh
      if [ -f "$BASH_ALIASES_PROJECT_FOLDER/config/bash_prompt_zsh" ]; then
        echoLine "* Creating the ~/.bash_prompt file"
        echoLine "* copying $BASH_ALIASES_PROJECT_FOLDER/config/bash_prompt_zsh"
        echoLine "* to $HOME_PROMPT"
        touch ${HOME_PROMPT} && cp $BASH_ALIASES_PROJECT_FOLDER/config/bash_prompt_zsh ${HOME_PROMPT}
      else
        # Fallback to regular prompt if zsh-specific one doesn't exist
        echoLine "* Creating the ~/.bash_prompt file"
        echoLine "* copying $BASH_ALIASES_PROJECT_FOLDER/config/bash_prompt (zsh-specific not found)"
        echoLine "* to $HOME_PROMPT"
        touch ${HOME_PROMPT} && cp $BASH_ALIASES_PROJECT_FOLDER/config/bash_prompt ${HOME_PROMPT}
      fi
    else
      # For other OS or shells
      echoLine "* Creating the ~/.bash_prompt file"
      echoLine "* copying $BASH_ALIASES_PROJECT_FOLDER/config/bash_prompt"
      echoLine "* to $HOME_PROMPT"
      touch ${HOME_PROMPT} && cp $BASH_ALIASES_PROJECT_FOLDER/config/bash_prompt ${HOME_PROMPT}
    fi
  else
    echoLine "* ~/.bash_prompt already exists, moving on"
  fi
}

# This will update the terminal configurations
updateBashTerminal() {
  echoHeader "[Update Bash Terminal]: "

  OS=$(getOperationalSystem)
  echoLine "* OS: $OS"
  
  # For macOS with zsh
  if [ "$OS" = "mac" ]; then
    if [ -f ~/.zshrc ]; then
      # Instead of sourcing which can cause errors, just report success
      echoLine "* updating terminal ~/.zshrc"
      exec zsh
      # echoLine "[INFO]: Please run 'source ~/.zshrc' manually to apply changes"
    else
      echoLine "[ERR]: missing file ~/.zshrc"
    fi
  # For other systems using bash
  else
    if [ -f "${HOME_PROFILE}" ]; then
      exec $SHELL
      echoLine "* updating terminal ${HOME_PROFILE}"
    else
      echoLine "[ERR]: missing file ${HOME_PROFILE}"
    fi
  fi
}


## This will make sure that will exist on the ~/.bash_profile or ~/.zshrc the lines:
##
## if [ -f ~/.bash_aliases ]; then
##    . ~/.bash_aliases
## fi
##
## if [ -f ~/.bash_prompt ]; then
##    . ~/.bash_prompt
## fi
upgradeElementsOnBashProfile() {

  echoMainHeader "Strubloid BashAliases v2.0 "
  echoPunchHeader "I am here for ye! "

  echoHeader "[Upgrade Elements On Bash Profile]: "
  
  # Determine the correct profile file based on the shell
  PROFILE_FILE=${HOME_PROFILE}
  
  # For macOS, check if we're using zsh
  OS=$(getOperationalSystem)
  if [ "$OS" = "mac" ] && [ "$SHELL" = "/bin/zsh" -o -n "$ZSH_VERSION" ]; then
    PROFILE_FILE="$HOME/.zshrc"
    echoLine "* Using ~/.zshrc for macOS with zsh"
  fi
  
  ## checking if exist the ~/.bash_g into profile
  checkStringExistIntoFile "~/.bash_global" ${PROFILE_FILE}
  EXIST_GLOBAL=$?

  ## This will add if the result isn't on profile
  if [[ ${EXIST_GLOBAL} -eq "0" ]]; then
    printf "\n" >>${PROFILE_FILE} && echo "${BASH_GLOBAL_LINE}" >>${PROFILE_FILE}
  else
    echoLine "* ~/.bash_global already exists, moving on"
  fi

  ## checking if exist the ~/.bash_aliases into profile
  checkStringExistIntoFile "~/.bash_variables" ${PROFILE_FILE}
  EXIST_VARIABLES=$?

  ## This will add if the result isn't on profile
  if [[ ${EXIST_VARIABLES} -eq "0" ]]; then
    printf "\n" >>${PROFILE_FILE} && echo "${BASH_VARIABLES_LINE}" >>${PROFILE_FILE}
  else
    echoLine "* ~/.bash_variables already exists, moving on"
  fi

  ## checking if exist the ~/.bash_aliases into profile
  checkStringExistIntoFile "~/.bash_aliases" ${PROFILE_FILE}
  EXIST_ALIAS=$?

  ## This will add if the result isn't on profile
  if [[ ${EXIST_ALIAS} -eq "0" ]]; then
    printf "\n" >>${PROFILE_FILE} && echo "${BASH_ALIASES_LINE}" >>${PROFILE_FILE}
  else
    echoLine "* ~/.bash_aliases already exists, moving on"
  fi

  ## checking if exist the ~/.bash_prompt into profile
  checkStringExistIntoFile "~/.bash_prompt" ${PROFILE_FILE}
  EXIST_PROMPT=$?

  ## This will add if the result isn't on profile
  if [[ ${EXIST_PROMPT} -eq "0" ]]; then
    printf "\n" >>${PROFILE_FILE} && echo "${BASH_PROMPT_LINE}" >>${PROFILE_FILE}
  else
    echoLine "* ~/.bash_prompt already exists, moving on"
  fi

  # Check if the bash_prompt file exists
  if [ -f "${HOME_PROMPT}" ]; then
    # Make sure OS is set
    OS=$(getOperationalSystem)
    
    # File exists, update it regardless of content
    echoLine "* ~/.bash_prompt updating"

    # For macOS with zsh, copy the zsh-specific prompt
    if [ "$OS" = "mac" ]; then
      cp $BASH_ALIASES_PROJECT_FOLDER/config/bash_prompt_zsh ${HOME_PROMPT}
    fi

    # Linux conditional update of the bash_prompt
    if [ "$OS" = "linux" ]; then
      cp $BASH_ALIASES_PROJECT_FOLDER/config/bash_prompt ${HOME_PROMPT}
    fi
  else
    echoLine "* ~/.bash_prompt does not exist, skipping update"
  fi
}

## Generation/replacement of the .bash_aliases file
generateBashAlias() {
  echoHeader "[Generate Bash Alias]: "

  # getting what is the operational system
  operationalSystem=$(getOperationalSystem)
  echoLine "[DEBUG]: Operating system detected: $operationalSystem"

  # removing the temp file bash_temp if it exists
  if [ -f "${BASH_TEMPORARY_F}" ]; then
    rm -f "${BASH_TEMPORARY_F}"
    echoLine "[DEBUG]: Removed existing temp file ${BASH_TEMPORARY_F}"
  fi

  # Create a basic template for the aliases file
  echo "# Generated bash aliases by strubloid's bash_aliases project" > ${BASH_TEMPORARY_F}
  echo "# $(date)" >> ${BASH_TEMPORARY_F}
  echo "" >> ${BASH_TEMPORARY_F}

  # Define folders based on operational system
  generalFolder="$BASH_ALIASES_PROJECT_FOLDER/aliases/general"
  osFolder=""
  
  # Set the OS-specific folder
  case "$operationalSystem" in
    mac)    osFolder="$BASH_ALIASES_PROJECT_FOLDER/aliases/mac" ;;
    linux)  osFolder="$BASH_ALIASES_PROJECT_FOLDER/aliases/linux" ;;
    *)      echoLine "[WARN]: Unsupported OS: $operationalSystem, using only general aliases" ;;
  esac
  
  # Display debug info about which folders we're using
  echoLine "[DEBUG]: Looking for aliases in folders:"
  echoLine "* $generalFolder"
  if [ -n "$osFolder" ]; then
    echoLine "* $osFolder"
  fi
  
  # Process all aliases (general and OS-specific) in one loop
  for folder in "$generalFolder" "$osFolder"; do
    # Skip empty folders (in case OS folder wasn't set)
    if [ -z "$folder" ] || [ ! -d "$folder" ]; then
      continue
    fi
    
    # Process all .sh files in the folder
    for file in "$folder"/*.sh; do
      if [ -f "$file" ]; then
        echoLine "[DEBUG]: Processing $file"
        echo "# Source from: $file" >> ${BASH_TEMPORARY_F}
        
        # Extract content excluding shebang
        awk 'NR==1 && /^#!/ {next} {print}' "$file" >> ${BASH_TEMPORARY_F}
        
        echo "" >> ${BASH_TEMPORARY_F}
        echo "# End of $file" >> ${BASH_TEMPORARY_F}
        echo "" >> ${BASH_TEMPORARY_F}
      fi
    done
  done

  # updating the file on the operational system
  if [ -s "${BASH_TEMPORARY_F}" ]; then
    cp ${BASH_TEMPORARY_F} ${HOME_ALIASES}
    echoLine "* creating $HOME/.bash_aliases"
  else
    echo "# No aliases found" > ${HOME_ALIASES}
    echoLine "[WARN]: Created empty $HOME/.bash_aliases (no alias files found)"
  fi

  # removing the temp file bash_temp
  if [ -f "${BASH_TEMPORARY_F}" ]; then
    rm -f "${BASH_TEMPORARY_F}"
    echoLine "* remove temp file ${BASH_TEMPORARY_F}"
  fi
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
    echoLine "* BASH_ALIASES_PROJECT_FOLDER already exists, moving on"
  fi

}

## this will move the scripts from scripts folder to the correct
## .bash_aliases_scripts
moveScripts(){

    echoHeader "[Move Scripts]:"

    checkFolderExists "$BASH_ALIASES_SCRIPTS"
    RETURN_CODE=$?

    ## checking if folder doesn't exist
    printf "  * Exist Folder? "
    if [[ ${RETURN_CODE} -eq "0" ]]; then
      printf "No, creating a new one\n"
      mkdir -p "$BASH_ALIASES_SCRIPTS"
    else
      printf "Yes\n"
    fi

    ## loading the scripts folder
    BASH_PROJECT_SCRIPS_LOCAL="$BASH_ALIASES_PROJECT_FOLDER/scripts"

    echoLine "* Copying"
    echoLine "📤 From: $BASH_PROJECT_SCRIPS_LOCAL"
    echoLine "📥 To: $BASH_ALIASES_SCRIPTS"
    cp $BASH_ALIASES_PROJECT_FOLDER/scripts/* $BASH_ALIASES_SCRIPTS

}