#!/bin/bash

source $(pwd)/config/global/variables.sh
source $(pwd)/config/manager.sh

# Step 1: check if exists, if not will create the .bash_alias file
setupBashAliasFile

# Step 2 Setup of the Environment Variables
setupEnvironmentVariable

# Step 3: checking if exits, if not will create the .bash_profile file
setupBashProfileFile

# Step 4: checking if exits, if not will create the .bash_profile file
setupBashVariablesFile

# Step 5: checking if exits, if not will create the .bash_prompt file
setupBashPromptFile

# Step 6: upgrade of the configurations on bash_profile
upgradeElementsOnBashProfile

# Step 7: Generation of the bash_alias file
generateBashAlias

# Step 8 Update the bash terminal
updateBashTerminal
