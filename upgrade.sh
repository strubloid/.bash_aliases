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

# step 3:  loading list of files to read
#filesToUpdate= loadFilesToUpdate ${operationalSystem}
loadFilesToUpdate ${operationalSystem}
printf "[Step 3] Loading all required files\n"

# step 4: creating a new export file
$(createBashAliasExportedFile)
printf "[Step 4] Creating a new .bash_aliases_export file\n"

# step 5: mounting the file with all the aliases together
$(createBashAliasExportFile)
printf "[Step 5] Populating a .bash_aliases_export file\n"

# step 6: cleaning the files_to_read.txt
$(cleanFilesToReadTxt)
printf "[Step 6] removing the files_to_read.txt file\n"

# step 7:  copying the .bash_aliases_export file to .bash_alias file
 cp ${EXPORTEDFILE} ${HOME_ALIASES}
printf "[Step 7] updating the ${HOME_ALIASES}\n"

# step 8:  Updating  ${BASHRC}
source ${BASHRC}
exec bash
printf "[Step 8] Updating the ${BASHRC}"
