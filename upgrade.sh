#!/bin/bash
source config/manager.sh

# Step 1: Configuration upgrades
upgradeElementsOnBashProfile

# Step 2: Generation of the bash_alias file
generateBashAlias

# Step 3 Update the bash terminal
updateBashTerminal
