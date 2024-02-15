#!/bin/bash

# Root folder for the bash_aliases project
PWD_PROJECT_FOLDER=$(pwd)

## It will be adding variables to the bash_profile file
BASHRC_FILE="$HOME/.bashrc"

## Building how should be the line to write inside of bash_profile
PATH_VARIABLE=$(cat << END
export PATH="$PATH:/usr/games:/usr/local/games:/snap/bin:/usr/local/git/bin:/usr/local/sbin:/usr/local/mysql/bin"
END
)


# Configuration of the bashAliasesProject folder
BASH_ALIASES_PROJECT_FOLDER_LINE=$(cat << END
export BASH_ALIASES_PROJECT_FOLDER=${PWD_PROJECT_FOLDER}
END
)

# Project separator line
SEPARATOR_BEFORE="#strubloid# .bash_aliases project global variables"
SEPARATOR_AFTER="#strubloid# .bash_aliases project global variables"

# configuration that will be insert in the ~/.bashrc
BASH_PROFILE_CONFIGURATION_LINE=$(cat << END
\n
$SEPARATOR_BEFORE\n
$PATH_VARIABLE\n
$BASH_ALIASES_PROJECT_FOLDER_LINE\n
$SEPARATOR_AFTER\n

END
)

## Adding only if not exist that line
if ! grep -q "$SEPARATOR_BEFORE" "$BASHRC_FILE"; then

  BASH_PROFILE_LINE_CHECK="if [ -f ~/.bash_profile ]; then"
  if ! grep -qF "$BASH_PROFILE_LINE_CHECK" "$BASHRC_FILE"; then
    echo -e ${BASH_PROFILE_CONFIGURATION_LINE} >> ${BASHRC_FILE}
  else
    BASH_PROFILE_UPGRADE_LINE=$(awk -v pattern="if.*.bash_profile.*then" \
        -v line1="$SEPARATOR_BEFORE" -v line2="$PATH_VARIABLE" \
        -v line3="$BASH_ALIASES_PROJECT_FOLDER_LINE" \
        -v line4="$SEPARATOR_AFTER" \
        "\$0 ~ pattern {print \"\"; print line1; print line2; print line3; print line4; print \"\"; print; next} 1" "$BASHRC_FILE")

    echo -e "$BASH_PROFILE_UPGRADE_LINE" > "$BASHRC_FILE"
  fi
fi


## Multiline variable sample
#EXAMPLE1=$(cat << END
#
## You can add comments
#any.kind.of.variables=100
#
#END
#)
#
#read -r -d '' EXAMPLE1 << EOM
#This is line 1.
#This is line 2.
#Line 3.
#EOM

