#!/bin/bash

# Root folder for the bash_aliases project
PWD_PROJECT_FOLDER=$(pwd)

## It will be adding variables to the bash_profile file
BASHRC_FILE="$HOME/.bashrc"

## export PATH="/usr/local/bin:/usr/bin:/usr/local:/usr/sbin:/sbin:/bin" - minimum on your .bashrc

## Building how should be the line to write inside of bash_profile
PATH_VARIABLE=$(cat << END
export PATH="$PATH:/usr/games:/usr/local/games:/snap/bin:/usr/local/git/bin:/usr/local/sbin:/usr/local/mysql/bin"
END
)

BASH_ALIASES_PROJECT_FOLDER_LINE=$(cat << END
export BASH_ALIASES_PROJECT_FOLDER=${PWD_PROJECT_FOLDER}
END
)

SEPARATOR_BEFORE="#strubloid# .bash_aliases project global variables"
SEPARATOR_AFTER="#strubloid# .bash_aliases project global variables\n"

## Adding only if not exist that line
if ! grep -q "$SEPARATOR_BEFORE" "$BASHRC_FILE"
then

  sed -i "s/if \[ -f ~\/\.bash_profile \]; then/\n&/g" $BASHRC_FILE
  sed -i "/if \[ -f ~\/\.bash_profile \]; then/i $SEPARATOR_BEFORE" $BASHRC_FILE
  sed -i "/if \[ -f ~\/\.bash_profile \]; then/i $PATH_VARIABLE" $BASHRC_FILE
  sed -i "/if \[ -f ~\/\.bash_profile \]; then/i $BASH_ALIASES_PROJECT_FOLDER_LINE" $BASHRC_FILE
  sed -i "/if \[ -f ~\/\.bash_profile \]; then/i $SEPARATOR_AFTER" $BASHRC_FILE

fi
