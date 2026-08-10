#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source the required files using absolute paths
source "$SCRIPT_DIR/config/global/variables.sh"
source "$SCRIPT_DIR/config/manager.sh"

# Step 1: Configuration upgrades
upgradeElementsOnBashProfile

# Step 2: Generation of the bash_alias file
generateBashAlias

# Step 3 Update the bash terminal
updateBashTerminal

## Step 4 Move usable scripts
moveScripts

## Step 5 move Docker compose ideas
moveDockerComposeIdeas