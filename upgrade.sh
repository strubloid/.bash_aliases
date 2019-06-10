#!/bin/bash

## loading main functions as well action ones
source config/functions.sh
source config/actions.sh

# step 1: finding what is the operational system
operationalSystem=$(getOperationalSystem);
printf "[Step 1]: Finding OS: ${operationalSystem}\n"

# step 2: removing the .bash_aliases_exported file
$(removeBashAliasExportedFile)
printf "[Step 2] Removing the file .bash_aliases_export, if exists\n"

# step 3:   creating a new export file
createBashAliasExportedFile ${operationalSystem}
printf "[Step 3] Loading all required files\n"

# step 4: mounting the file with all the aliases together
#$(createBashAliasExportFile)
printf "[Step 4] Populating a .bash_aliases_export file\n"

# step 5:  copying the .bash_aliases_export file to .bash_alias file
cp ${EXPORTEDFILE} ${HOME_ALIASES}
printf "[Step 5] updating the ${HOME_ALIASES}\n"

# step 6:  Updating  ${BASHRC}
source ${BASHRC}
exec bash
printf "[Step 6] Updating the ${BASHRC}"
