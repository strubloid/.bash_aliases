#!/bin/bash

source $(pwd)/config/global/variables.sh
source $(pwd)/config/manager.sh

# Step 1: check if exists, if not will create the .bash_alias file
setupBashAliasFile

# Step 2: checking if exits, if not will create the .bash_profile file
setupBashProfileFile

# Step 3: checking if exits, if not will create the .bash_prompt file
setupBashPromptFile

# Step 4: checking if exits, if not will create the .bash_g file
setupBashGlobalFile

# Step 5: upgrade of the configurations on bash_profile
upgradeElementsOnBashProfile

# Step 6: Generation of the bash_alias file
generateBashAlias

# Step 7 Update the bash terminal
updateBashTerminal
