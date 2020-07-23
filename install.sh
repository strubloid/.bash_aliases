#!/bin/bash

source config/manager.sh

# Step 1: check if exists, if not will create the .bash_alias file
setupBashAliasFile

# Step 2: checking if exits, if not will create the .bash_profile file
setupBashProfileFile
# TODO: check if it is inside of the profile if not, add it!

# Step 3: checking if exits, if not will create the .bash_prompt file
setupBashPromptFile

# Step 4 Check fi exists the line inside of bash_profile,
# if not should be added
checkIfExistBashPromptAndAlias

# Step 5: Generation of the bash_alias file
generateBashAlias

# Step 6 Update the bash terminal
updateBashTerminal
