#!/bin/bash

# Strubloid::linux::git

# git aliases
alias git-revert="git clean -d -f -f"
alias gitup-master="git checkout master && git pull origin master && git fetch --all"

git-check-if-works-the-connection(){
  ssh -T git@github.com -v
}

git-compare-with-master(){
  git diff --name-status origin/master...HEAD
}

# Interactive branch selection menu for git-compare-improved
# Args: $1 = current_branch, $@ = branches
# On success: sets SELECTED_BRANCH and returns 0
# On cancel (Esc): returns 1
git-compare-improved-branch-menu() {
  local current_branch="$1"
  shift
  local -a branches=("$@")
  local selected=0
  local key=""

  while true; do
    clear
    echo "Choose a branch to compare with $current_branch:"
    echo ""

    for i in "${!branches[@]}"; do
      if [ "$i" -eq "$selected" ]; then
        echo -e "▶ \033[1;36m${branches[$i]}\033[0m"
      else
        echo "  ${branches[$i]}"
      fi
    done

    echo ""
    echo -e "\033[1;33mCompare $current_branch with ${branches[$selected]}\033[0m"
    echo ""
    echo "Use ↑/↓ (k/j) to navigate, Enter to select, Esc to cancel"

    read -s -n 1 key

    if [[ $key == $'\e' ]]; then
      read -s -n 2 -t 0.1 key2
      if [[ $key2 == "[A" ]] || [[ $key == "k" ]]; then
        selected=$(( (selected - 1 + ${#branches[@]}) % ${#branches[@]} ))
      elif [[ $key2 == "[B" ]] || [[ $key == "j" ]]; then
        selected=$(( (selected + 1) % ${#branches[@]} ))
      elif [[ -z "$key2" ]]; then
        echo "Operation cancelled"
        return 1
      fi
    elif [[ $key == "k" ]]; then
      selected=$(( (selected - 1 + ${#branches[@]}) % ${#branches[@]} ))
    elif [[ $key == "j" ]]; then
      selected=$(( (selected + 1) % ${#branches[@]} ))
    elif [[ $key == "" ]]; then
      SELECTED_BRANCH="${branches[$selected]}"
      return 0
    fi
  done
}

# Interactive comparison options menu for git-compare-improved
# Args: $1 = current_branch, $2 = selected_branch, $@ = options
# On success: sets SELECTED_OPTION and returns 0
# On cancel (Esc): returns 1
git-compare-improved-options-menu() {
  local current_branch="$1"
  local selected_branch="$2"
  shift 2
  local -a options=("$@")
  local -a descriptions=(
    "Lists modified files without showing their content"
    "Shows complete diff output for all changed files"
    "Interactive selection of individual files to view"
  )
  local selected=0
  local key=""

  while true; do
    clear
    echo "Choose comparison option between $current_branch and $selected_branch:"
    echo ""

    for i in "${!options[@]}"; do
      if [ "$i" -eq "$selected" ]; then
        echo -e "▶ \033[1;36m${options[$i]}\033[0m"
      else
        echo "  ${options[$i]}"
      fi
    done

    echo ""
    echo -e "\033[1;33m${descriptions[$selected]}\033[0m"
    echo ""
    echo "Use ↑/↓ (k/j) to navigate, Enter to select, Esc to cancel"

    read -s -n 1 key

    if [[ $key == $'\e' ]]; then
      read -s -n 2 -t 0.1 key2
      if [[ $key2 == "[A" ]] || [[ $key == "k" ]]; then
        selected=$(( (selected - 1 + ${#options[@]}) % ${#options[@]} ))
      elif [[ $key2 == "[B" ]] || [[ $key == "j" ]]; then
        selected=$(( (selected + 1) % ${#options[@]} ))
      elif [[ -z "$key2" ]]; then
        echo "Operation cancelled"
        return 1
      fi
    elif [[ $key == "k" ]]; then
      selected=$(( (selected - 1 + ${#options[@]}) % ${#options[@]} ))
    elif [[ $key == "j" ]]; then
      selected=$(( (selected + 1) % ${#options[@]} ))
    elif [[ $key == "" ]]; then
      SELECTED_OPTION="$selected"
      return 0
    fi
  done
}

# Interactive file selection menu for git-compare-improved
# Args: $@ = changed files
# On success: sets SELECTED_FILE and returns 0
# On cancel (Esc): returns 1
git-compare-improved-file-menu() {
  local -a files=("$@")
  local file_selected=0
  local key=""

  while true; do
    clear
    echo "Choose a file to view diff:"
    echo ""

    for i in "${!files[@]}"; do
      if [ "$i" -eq "$file_selected" ]; then
        echo -e "▶ \033[1;36m${files[$i]}\033[0m"
      else
        echo "  ${files[$i]}"
      fi
    done

    echo ""
    echo -e "\033[1;33mFile: ${files[$file_selected]}\033[0m"
    echo ""
    echo "Use ↑/↓ (k/j) to navigate, Enter to select, Esc to cancel"

    read -s -n 1 key

    if [[ $key == $'\e' ]]; then
      read -s -n 2 -t 0.1 key2
      if [[ $key2 == "[A" ]] || [[ $key == "k" ]]; then
        file_selected=$(( (file_selected - 1 + ${#files[@]}) % ${#files[@]} ))
      elif [[ $key2 == "[B" ]] || [[ $key == "j" ]]; then
        file_selected=$(( (file_selected + 1) % ${#files[@]} ))
      elif [[ -z "$key2" ]]; then
        echo "Operation cancelled"
        return 1
      fi
    elif [[ $key == "k" ]]; then
      file_selected=$(( (file_selected - 1 + ${#files[@]}) % ${#files[@]} ))
    elif [[ $key == "j" ]]; then
      file_selected=$(( (file_selected + 1) % ${#files[@]} ))
    elif [[ $key == "" ]]; then
      SELECTED_FILE="${files[$file_selected]}"
      return 0
    fi
  done
}

# Interactive git comparison tool with branch selection and diff options
git-compare-improved() {
  # Get current branch
  CURRENT_BRANCH=$(git branch --show-current)
  echo "[3.0] Current branch: $CURRENT_BRANCH"

  # Get all branches except current branch
  BRANCHES=($(git branch --format='%(refname:short)' | grep -v "^$CURRENT_BRANCH$"))

  # Check if there are other branches
  if [ ${#BRANCHES[@]} -eq 0 ]; then
    echo "No other branches available to compare with."
    return 1
  fi

  # Branch selection
  git-compare-improved-branch-menu "$CURRENT_BRANCH" "${BRANCHES[@]}" || return 1

  # Show comparison options
  echo ""
  echo "Choose comparison option:"

  # Define options
  OPTIONS=(
    "Show changed files (names only)"
    "Show all differences (complete diff)"
    "Show list of changed files"
  )

  # Comparison option menu
  git-compare-improved-options-menu "$CURRENT_BRANCH" "$SELECTED_BRANCH" "${OPTIONS[@]}" || return 1

  # Process the selected option
  case $((SELECTED_OPTION + 1)) in
      1)
        # Just dump the file names and status directly to terminal with color
        git diff --name-status --color "$CURRENT_BRANCH".."$SELECTED_BRANCH"
        ;;

      2)
        # Run git diff with color and pipe to cat to avoid pager but maintain colors
        git -c color.ui=always diff "$CURRENT_BRANCH".."$SELECTED_BRANCH" | cat
        ;;

      3)
        # Get list of files that have changed
        CHANGED_FILES=($(git diff --name-only "$CURRENT_BRANCH".."$SELECTED_BRANCH"))

        if [ ${#CHANGED_FILES[@]} -eq 0 ]; then
          echo "No changed files between $CURRENT_BRANCH and $SELECTED_BRANCH."
          return 0
        fi

        # View files in a loop, allowing the user to pick another one
        while true; do
          git-compare-improved-file-menu "${CHANGED_FILES[@]}" || return 1

          # Show diff for selected file with color
          clear
          echo "Showing diff for: $SELECTED_FILE"
          echo "-------------------------------------------"
          git -c color.ui=always diff "$CURRENT_BRANCH".."$SELECTED_BRANCH" -- "$SELECTED_FILE" | cat

          # Ask if user wants to see another file
          echo ""
          read -p "View another file? [Y/n]: " VIEW_ANOTHER
          # Default to yes if user just presses Enter
          if [[ "$VIEW_ANOTHER" =~ ^[Nn]$ ]]; then
            break
          fi
        done
        ;;
      *)
        echo "Invalid option. Please select 1, 2, or 3."
        ;;
    esac
}

git-clean-merged(){
  git branch --merged | egrep -v "(^\*|master|dev)" | xargs git branch -d
}

git-clean-unmerged()
{
  git branch --no-merged | egrep -v "(^\*|master|dev)" | xargs git branch -D
}

git-clean-all()
{
  git branch | egrep -v "(^\*|master|dev)" | xargs git branch -D
}

## This will update the develop branch after push code into the master
git-update-develop-with-master(){

  git checkout develop && git merge master && git push origin develop && git checkout master

}

# This will update the master branch
git-update-master() {
  printf "[MASTER] - "
  git checkout master -q && git pull origin master -q  && git checkout . -q
  printf "OK\n"
}

# This will update the develop branch
git-update-develop() {
  printf "[DEVELOP] - "
  git checkout develop -q && git pull origin develop -q && git checkout . -q
  printf "OK\n"
}

# This will update the main branch
git-update-main() {
  printf "[MAIN] - "
  git checkout main -q && git pull origin main -q && git checkout . -q
  printf "OK\n"
}

# This will update if you still have release branches in your local machine
update-release() {
  CURRENT_RELEASE_BRANCH=$(git branch -l | grep -Po 'release.*')
  if [[ ! -z "$CURRENT_RELEASE_BRANCH" ]]; then
    git checkout "$CURRENT_RELEASE_BRANCH" && git pull origin "$CURRENT_RELEASE_BRANCH"
    echo "[$CURRENT_RELEASE_BRANCH] - UPDATED"
  fi
}

## This will be the quick shortcut, to:
## 1 - add the new things
## 2 - add a message
## 3 - update the same branch on the remote
## 4 - update the master
## 5 - update the develop
commit-update-git() {

  # Getting the current branch name
  CURRENT_BRANCH=$(git branch --show-current)

  # Loading the commit message
  if [ -z "$1" ]
  then
      read -p "[Commit Message]: " COMMIT_MESSAGE
  else
      # mounting the commit message in the format that jira accepts
      COMMIT_MESSAGE="$1"
  fi

  # Loading should update the base code
  if [ -z "$2" ]
  then
      read -p "Update Master/Develop [y/n] : " UPDATE_MASTER_DEVELOPER
  else
      # mounting the commit message in the format that jira accepts
      UPDATE_MASTER_DEVELOPER="$1"
  fi

  echo "-----------------------------------------------------------------------------"
  echo "  GIT  Commit  --------------------------------------------------------------"
  echo "-----------------------------------------------------------------------------"
  echo "[CURRENT BRANCH] - $CURRENT_BRANCH"
  echo "[COMMIT MESSAGE] - $COMMIT_MESSAGE"
  echo "-----------------------------------------------------------------------------"

  # commit of the thing
  printf "[COMMIT] - "
  git add . && git commit -m "$COMMIT_MESSAGE" -q && git push origin "$CURRENT_BRANCH" -q
  printf "OK\n"

  ## check if the update was passed with y/yes as an option
  if [[ "$UPDATE_MASTER_DEVELOPER" =~ [yY](es)?$ ]]; then

    # Update of the other branches if needed
    developBranch="develop"
    masterBranch="master"

    echo "[UPDATES] - Master & Develop "
    if [[ "$CURRENT_BRANCH" == "$masterBranch" ]]; then
      git-update-develop
    elif [[ "$CURRENT_BRANCH" == "$developBranch" ]]; then
      git-update-master
    else
        git-update-develop
        git-update-master
    fi

  fi

  # this will be back to your current branch that you are working on
  git checkout "$CURRENT_BRANCH" -q
}

## This will be the quick shortcut, to:
## 1 - add the new things
## 2 - add a message
## 3 - update the same branch on the remote
## 4 - update the main
commit-update-master-git() {

  # Getting the current branch name
  CURRENT_BRANCH=$(git branch --show-current)

  # Loading the commit message
  if [ -z "$1" ]
  then
      read -p "[Commit Message]: " COMMIT_MESSAGE
  else
      # mounting the commit message in the format that jira accepts
      COMMIT_MESSAGE="$1"
  fi

  # Loading should update the base code
  if [ -z "$2" ]
  then
      read -p "Update Main [y/n] : " UPDATE_MAIN
  else
      # mounting the commit message in the format that jira accepts
      UPDATE_MAIN="$1"
  fi

  echo "-----------------------------------------------------------------------------"
  echo "  GIT  Main Commit  ----------------------------------------------------------"
  echo "-----------------------------------------------------------------------------"
  echo "[CURRENT BRANCH] - $CURRENT_BRANCH"
  echo "[COMMIT MESSAGE] - $COMMIT_MESSAGE"
  echo "-----------------------------------------------------------------------------"

  # commit of the thing and push
  printf "[COMMIT] - "
  git add . && git commit -m "$COMMIT_MESSAGE" -q && git push origin "$CURRENT_BRANCH" -q
  printf "OK\n"

  ## check if the update was passed with y/yes as an option
  if [[ "$UPDATE_MAIN" =~ [yY](es)?$ ]]; then

    # Update of the other branches if needed
    mainBranch="main"

    echo "[UPDATES] - Main "
    if [[ "$CURRENT_BRANCH" != "$mainBranch" ]]; then
      git-update-main
    fi

  fi

  # this will be back to your current branch that you are working on
  git checkout "$CURRENT_BRANCH" -q
}


## This will be the quick shortcut, to:
## 1 - add the new things
## 2 - add a message
## 3 - update the same branch on the remote
commit-git() {

  # Loading the commit message
  if [ -z "$1" ]
  then
      read -p "[Commit Message]: " COMMIT_MESSAGE
  else
      # mounting the commit message in the format that jira accepts
      COMMIT_MESSAGE="$1"
  fi

  commit-update-git "$COMMIT_MESSAGE" "No"

}

## This will be the quick shortcut, to:
## 1 - add the new things
## 2 - add a message
## 3 - update the same branch on the remote
## 4 - update the update-system branch
commit-site() {

  # Loading the commit message
  if [ -z "$1" ]
  then
      read -p "[Commit Message]: " COMMIT_MESSAGE
  else
      # mounting the commit message in the format that jira accepts
      COMMIT_MESSAGE="$1"
  fi

  commit-update-site "$COMMIT_MESSAGE" "yes"

}

## This will get the current branch and save a commit message
## then it will commit and push the code to the server and after that
## it will update the update-system branch if the user want to do that
commit-update-site() {

  # Getting the current branch name
  CURRENT_BRANCH=$(git branch --show-current)

  # Loading the commit message
  if [ -z "$1" ]
  then
      read -p "[Commit Message]: " COMMIT_MESSAGE
  else
      # mounting the commit message in the format that jira accepts
      COMMIT_MESSAGE="$1"
  fi

  # Loading should update the base code
  if [ -z "$2" ]
  then
      read -p "Update the update-system branch? [y/n] : " UPDATE_SYSTEM_BRANCH
  else
      # mounting the commit message in the format that jira accepts
      UPDATE_SYSTEM_BRANCH="$2"
  fi

  echo "-----------------------------------------------------------------------------"
  echo "  GIT  Commit  --------------------------------------------------------------"
  echo "-----------------------------------------------------------------------------"
  echo "[CURRENT BRANCH] - $CURRENT_BRANCH"
  echo "[COMMIT MESSAGE] - $COMMIT_MESSAGE"
  echo "-----------------------------------------------------------------------------"

  # commit of the thing
  printf "[COMMIT] - "
  git add . && git commit -m "$COMMIT_MESSAGE" -q && git push origin "$CURRENT_BRANCH" -q

  printf "OK\n"

  ## check if the update was passed with y/yes as an option
  if [[ "$UPDATE_SYSTEM_BRANCH" =~ [yY](es)?$ ]]; then
      
      echo "[UPDATES] - Update System Branch "
      git checkout update-system -q && git pull origin update-system -q && git merge "$CURRENT_BRANCH" -q && git push origin update-system -q 
  fi

  # this will be back to your current branch that you are working on
  git checkout "$CURRENT_BRANCH" -q
}


commit-main() {

  # Loading the commit message
  if [ -z "$1" ]
  then
      read -p "[Commit Message]: " COMMIT_MESSAGE
  else
      # mounting the commit message in the format that jira accepts
      COMMIT_MESSAGE="$1"
  fi

  commit-update-master-git "$COMMIT_MESSAGE" "No"

}

# This will commit in git and push the code
commit()
{
  # Getting the current branch name
  CURRENT_BRANCH=$(git branch --show-current)

  # Getting the current branch ID for the commit
  CURRENT_BRANCH_ID=$(git branch --show-current | grep -Po 'BLCXT?-[0-9]*')

  # Commit message
  COMMIT_MESSAGE="$CURRENT_BRANCH_ID: $1"

  echo "-----------------------------------------------------------------------------"
  echo "------------------------------ Git Commit -----------------------------------"
  echo "-----------------------------------------------------------------------------"
  echo "[CURRENT BRANCH] - $CURRENT_BRANCH"
  echo "[JIRA ID] - $CURRENT_BRANCH_ID"
  echo "[COMMIT_MESSAGE] - $COMMIT_MESSAGE"
  echo "-----------------------------------------------------------------------------"

  # commit of the thing
  git add . && git commit -m "$COMMIT_MESSAGE" && git push origin "$CURRENT_BRANCH"
}


## this is the action that you need to do to reset a branch
# to a previous stage that was committed by mistake the other ones
## afterwards.
git-reset-hard(){

  # Getting the current branch name
  CURRENT_BRANCH=$(git branch --show-current)

  echo "[Reverting]: $CURRENT_BRANCH"
  read -p "can we continue? [y/N]" canContinue

  ## this will start only if a user is ok about what is the branch
  ## to revert
  if [[ "$canContinue" =~ ^(yes|y|Y|Yes|YES)$ ]]
  then

    # Loading the commit message
    if [ -z "$1" ]
    then
        read -p "[Branch ID]: " GIT_BRANCH_REFERENCE
    else
        GIT_BRANCH_REFERENCE="$1"
    fi

    GIT_LOG=$(git log | grep -q "$GIT_BRANCH_REFERENCE"; echo $?)

    ## checking if the log exist
    if [ "$GIT_LOG" -eq 0 ]; then

      ## git reset hard to that log id
      git reset --hard "$GIT_BRANCH_REFERENCE"

      ## git clean
      git clean -f

      ## update repository
      git push -f origin "$CURRENT_BRANCH"

    fi

  fi


}

## This wil copy over files from the git status changes
git-copy-status-changes() {

  ## Loading new git status files
  GIT_STATUS_FILES=$(git status --porcelain | grep '^??' | cut -d ' ' -f 2)

  # Loading Destination folder
  if [ -z "$1" ]
  then
      read -p "[Destination Folder]: " GIT_STATUS_DESTINATION_FOLDER
  else
      # mounting the commit message in the format that jira accepts
      GIT_STATUS_DESTINATION_FOLDER="$1"
  fi

  ## echo "==> $GIT_STATUS_DESTINATION_FOLDER"

  ## copy each file to the destination folder
  for file in $GIT_STATUS_FILES; do

      ## loading the destination to be rebuilt on destination folder
      RELATIVE_PATH=$(dirname "$file")

      ## create of the folder
      FOLDER_STRUCTURE_TO_REPLICATE="$GIT_STATUS_DESTINATION_FOLDER/$RELATIVE_PATH"
#      mkdir -p -q "$FOLDER_STRUCTURE_TO_REPLICATE"

      ## copy over the file to the destination
      cp "$file" "$FOLDER_STRUCTURE_TO_REPLICATE"

#      echo "Copied $file to $FOLDER_STRUCTURE_TO_REPLICATE"

      # Debug area
#      read -p "[Continue ?]: " CONTINUE_PROCESS
#      if [[ "$CONTINUE_PROCESS" =~ [nN](o)?$ ]]; then
#        break
#      fi

  done

}

# A correct way to remove a hotfix branch on localhost after merged with master branch by a code reviewer
gitflow-clean-hotfix()
{
    read -p "Hotfix Branch Name: " 
    if [ -z "$hotfixBranchName" ]
    then
        printf "[Err]: You must say what is the hotfix branch name to remove\m"
    else
        git flow hotfix delete $hotfixBranchName -f
    fi
}

# A correct way to remove a feature branch on localhost after merged with master branch by a code reviewer
gitflow-clean-feature()
{
    read -p "Hotfix Branch Name: " 
    if [ -z "$featureBranchName" ]
    then
        printf "[Err]: You must say what is the feature branch name to remove\m"
    else
        git flow feature delete $featureBranchName -f
    fi
}


git-multiple-hotfix-on()
{
  git config --set gitflow.multi-hotfix true
}

# git basic commands
alias gc="git commit -m"
alias gs="git status"

# tags
alias gt-tag-c="git tag "

gitupdate()
{
  git checkout master && git pull origin master && git checkout develop && git pull origin develop && git fetch --all
}

gittag()
{
    printf "Strubloid::GitTag\n"
    if [ -z "$1" ]
    then
      echo "Usage: Gittag [ a | add | -add | --add ] -> Add tag
                          [ d | del | -del | --del ] -> Delete tag
                          [ l | -l | --l | list | -list | --list ] -> List of tags"
      exit 2
    fi

    case "$1" in
        a | add | -add | --add )
            printf "Now you will be passing: Message, Tag name and Git Id (Optional)\n"
            printf "(Optional)-> Means that will get the current commitID\n"
            read -p "Message : " message
            read -p "Tag Name : " tag
            read -p "Git Hash : " hash

            printf "You said: $message | $tag | $hash | "

            if [ -z "$hash" ]
            then
              git tag -a "$tag" -m "$message"
            else
              git tag -a "$tag" -m "$message" "$hash"
            fi
        shift
        ;;
        d | del | -del | --del )
            git tag --list
            read -p "Tag Name to delete : " tag
            git tag --delete $tag

            # Git command to delete a tag into the server
            # pushing the delete command
            git push --delete origin $tag

            shift
            ;;

        l | -l | --l | list | -list | --list )
            printf "With Refs? (enter for yes) anything else for no!\n>"
            read refs
            if [ -z "$refs" ]
            then
                git show-ref --tags
            else
                git tag --list
            fi

            shift
            ;;
        -- )
            shift
            return 0
            ;;
        *)
            echo "Internal error!"
            return 0
            ;;
    esac
}

# Updating the tags action
gitUpdateTags()
{
    printf "Update tags?\n[Y or N]: "
    read updateTags
    if [ "$updateTags" == "Y" ] || [ "$updateTags" == "y" ]
    then
        # Git command to push all tags
        git push origin --tags
    fi
}

# Gitpush function that will provide a different way to push
# the content to the server
gitpush()
{
    printf "Add Everything?\n[Y or N]: "
    read addEverything
    if [ "$addEverything" == "Y" ] || [ "$addEverything" == "y" ]
    then
        git add . # Git command to add all tags
    fi

    printf "Message (Mandatory):\n* "
    read commitMessage

    if [ -z "$commitMessage" ]
    then
      printf "[ERR]: You must pass an argument to use this function"
    else
      printf "Git message: $commitMessage\n"
      git commit -m "$commitMessage" && git push origin master
    fi

}

c-c()
{
  currentBranch=$(git branch --show-current)
  branchTag=$( echo $currentBranch | grep -Eo 'TIKET-[0-9]{1,4}')

  # Showing differences to help the build of the message
  git status

  # Adding all files
  git add .

  printf "Message (Mandatory):\n[type the commit message]: "
  read commitMessage

  # Commit message
  echo "[message]: $branchTag: $commitMessage\n"
  git commit -m "$branchTag: $commitMessage"

  # Pushing to
  echo "[push to]: git push origin $currentBranch\n"
  git push origin $currentBranch
}



## This will ignore files from pushing changes from them
git-ignore-file-from-commit(){

  if [ -z "$1" ]
  then
    read -p "What is the file to remove from git status? " fileToRemoveFromGitStatus

    ## Making sure that the file exist before remove from the git status
    while [ ! -f "$fileToRemoveFromGitStatus" ]; do
        echo "[$fileToRemoveFromGitStatus]: does not exist"
        read -p "What is the file to remove from git status? " fileToRemoveFromGitStatus
    done
  else
    fileToRemoveFromGitStatus="$1"
  fi

  # This will run the removal of the file
  git update-index --assume-unchanged "$fileToRemoveFromGitStatus"

}

## Helper: reads multiline input into the named variable
## Usage: read-multiline VAR_NAME "prompt"
## Terminates when a line contains only "."
## (like mail/ed/sed - works regardless of blank lines in the content)
read-multiline() {
  local varname="$1"
  local prompt="$2"
  local input=""
  local line=""

  echo "$prompt"

  while IFS= read -r line; do
    if [ "$line" = "." ]; then
      break
    fi
    if [ -z "$input" ]; then
      input="$line"
    else
      input+=$'\n'"$line"
    fi
  done

  printf -v "$varname" '%s' "$input"
}

## This will rename the last commit message and force-push it to the remote
git-rename-last-commit(){

  # Get current branch and previous commit message
  CURRENT_BRANCH=$(git branch --show-current)
  PREVIOUS_COMMIT_MESSAGE=$(git log -1 --pretty=%B)

  if [ -z "$1" ]
  then
    read-multiline COMMIT_MESSAGE "[Paste new commit message (type '.' on a line by itself to finish)]: "
  else
    COMMIT_MESSAGE="$1"
  fi

  echo "-----------------------------------------------------------------------------"
  echo "  GIT  Rename Last Commit  --------------------------------------------------"
  echo "-----------------------------------------------------------------------------"
  echo "[CURRENT BRANCH] - $CURRENT_BRANCH"
  echo "-----------------------------------------------------------------------------"
  echo "[PREVIOUS COMMIT MESSAGE]"
  echo "$PREVIOUS_COMMIT_MESSAGE"
  echo "-----------------------------------------------------------------------------"
  echo "[NEW COMMIT MESSAGE]"
  echo "$COMMIT_MESSAGE"
  echo "-----------------------------------------------------------------------------"

  # amend the last commit with the new message
  git commit --amend -m "$COMMIT_MESSAGE"
  echo "[Commited] - OK"
  echo "-----------------------------------------------------------------------------"

  # ask if this commit was already pushed to the remote
  read -p "Is this commit pushed to the repo? [N/y]: " IS_PUSHED

  ## if the user confirms it was pushed, force-push the amended commit
  if [[ "$IS_PUSHED" =~ ^[yY](es)?$ ]]; then
  
    # push with --force-with-lease to avoid overwriting others' work
    git push --force-with-lease origin "$CURRENT_BRANCH"

    echo "[gitpush --force-with-lease origin $CURRENT_BRANCH] - OK"
    echo "-----------------------------------------------------------------------------"
  fi
}

## This will be checking if the branch exist, and if it does, it will pull the branch from the remote
git-pull-if-branch-exists(){
  local branch_name="$1"

  ## this will be checking if exist the branch_name, and will only run if exists.
  if git show-ref --verify --quiet "refs/heads/${branch_name}"; then
    echo "[$branch_name] - branch exists, pulling changes..."
    git checkout "$branch_name"
    git pull origin "$branch_name"
  fi
}

## this function will be checking if any of those branches bellow are updated and if they are, it will pull the changes
function git-update-main-branches(){

  local original_branch
  original_branch=$(git symbolic-ref --short HEAD 2>/dev/null)

  echo "[git] - Update main branches"
  echo "[$original_branch] - current branch"

  git-pull-if-branch-exists main
  git-pull-if-branch-exists master
  git-pull-if-branch-exists develop
  git-pull-if-branch-exists dev

  ## if the original branch is not empty, it will checkout to the original branch
  if [ -n "$original_branch" ]; then
    git checkout "$original_branch"
  fi

}

## This function will be creating the branch
function git-new-branch() {
  local branch_name="$1"
  if [ -z "$branch_name" ]; then
    read -p "Enter new branch name: " branch_name
  fi

  ##before we create a new branch we need to ensure that main branches are updated
  git-update-main-branches

  ## create the new branch and switch to it
  git checkout -b "$branch_name"
}

## Helper: refuse to run if the working tree has uncommitted changes
## (a rebase requires a clean tree to operate safely).
## Returns 0 if clean, 1 if dirty (with an error message printed).
git-check-working-tree-clean() {
  if ! git diff --quiet HEAD 2>/dev/null; then
    echo "[ERR]: Working tree has uncommitted changes. Commit or stash them first."
    return 1
  fi
}

## Resolves a base branch to diff/rebase against.
##
## Args:
##   $1 (optional) - branch name to use directly. Validated against local
##                   branches; errors if it doesn't exist.
##                   If omitted, an interactive picker is shown.
##
## Output:
##   stdout  - the resolved branch name (one line, no decoration)
##   stderr  - prompts (interactive picker) and any error messages
##
## Exit:
##   0  on success (result printed on stdout)
##   1  on error (message on stderr)
git-base-branch() {
  local CURRENT_BRANCH
  CURRENT_BRANCH=$(git branch --show-current)

  if [ -z "$CURRENT_BRANCH" ]; then
    echo "[ERR]: Not on a branch (detached HEAD?). Cannot determine scope." >&2
    return 1
  fi

  local BASE_BRANCH=""
  if [ -n "$1" ]; then
    if git show-ref --verify --quiet "refs/heads/${1}" 2>/dev/null; then
      BASE_BRANCH="$1"
    else
      echo "[ERR]: Base branch '$1' does not exist locally" >&2
      return 1
    fi
  else
    # Build a list of local branches excluding the current one
    local -a BRANCHES
    BRANCHES=($(git branch --format='%(refname:short)' | grep -v "^${CURRENT_BRANCH}$"))

    if [ ${#BRANCHES[@]} -eq 0 ]; then
      echo "[ERR]: No other branches available to compare against" >&2
      return 1
    fi

    echo "" >&2
    echo "  Pick a base branch to compare '$CURRENT_BRANCH' against:" >&2
    local i=1
    for branch in "${BRANCHES[@]}"; do
      printf "  [%d] %s\n" "$i" "$branch" >&2
      i=$((i+1))
    done

    local SELECTION
    read -p "  Selection [1]: " SELECTION
    SELECTION=${SELECTION:-1}

    if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] || [ "$SELECTION" -lt 1 ] || [ "$SELECTION" -gt "${#BRANCHES[@]}" ]; then
      echo "[ERR]: Invalid selection: '$SELECTION'" >&2
      return 1
    fi

    BASE_BRANCH="${BRANCHES[$((SELECTION-1))]}"
  fi

  # Print the resolved branch on stdout so callers can capture it cleanly
  printf "%s\n" "$BASE_BRANCH"
}

## Shows all commits on the current branch that are NOT in a base branch.
## Base branch resolution is delegated to `git-base-branch` (which handles
## the detached HEAD and invalid branch errors itself).
##
## Args:
##   $1 - REQUIRED base branch name. The function exits with an error if
##        this argument is missing. The branch must exist locally.
##
## Exits with an error if:
##   - $1 is missing
##   - On the base branch itself (no branch-specific commits to show)
##   - Any error from `git-base-branch` (detached HEAD, invalid branch, etc.)
get-branch-commits() {

  ## requires the first argument to be the branch to compare to
  if [ -z "$1" ]; then
    echo "[ERR]: get-branch-commits requires a base branch as the first argument"
    return 1
  fi

  # Resolve the base branch (delegated; also handles detached HEAD + invalid arg)
  local BASE_BRANCH
  BASE_BRANCH=$(git-base-branch "$1") || return 1

  local CURRENT_BRANCH
  CURRENT_BRANCH=$(git branch --show-current)

  if [ "$CURRENT_BRANCH" = "$BASE_BRANCH" ]; then
    echo "[ERR]: You are on the base branch ($BASE_BRANCH). No branch-specific commits to show."
    return 1
  fi

  local COMMIT_COUNT
  COMMIT_COUNT=$(git rev-list --count "${BASE_BRANCH}..HEAD")
  echo "[Commits on] $CURRENT_BRANCH"
  echo "[Not in] $BASE_BRANCH"
  echo "[Total] $COMMIT_COUNT commits"
  echo "-----------------------------------------------------------------------------"

  # --graph for visual branch topology
  # --color=always preserves colors when piped (through `cat`)
  # Custom format: hash | date | subject, then (author) and refs on a new line
  git log --graph --color=always \
    --pretty=format:"%C(yellow)%h%C(reset) %C(cyan)%ad%C(reset) %s%n  %C(green)(%an)%C(reset)%d" \
    --date=short "${BASE_BRANCH}..HEAD" | cat
  printf "\n-----------------------------------------------------------------------------\n\n"
}

## Interactive picker for what to do with each commit on the current branch
## that isn't in the given base branch. Walks commits oldest-first and asks
## the user to mark each one as:
##   [p]ick    = keep this commit as-is
##   [s]quash  = merge this commit into the previous one
##   [d]rop    = remove this commit entirely
##
## Args:
##   $1 - REQUIRED base branch. Commits on the current branch not in this
##        base are the candidates to act on.
##
## On success, populates these globals for the caller:
##   PICKED_HASHES    - full commit hashes (array, oldest first)
##   PICKED_MESSAGES  - commit subject lines (array)
##   PICKED_ACTIONS   - pick / squash / drop per commit (array)
##   PICKED_COUNT     - number of commits picked
##
## Exit:
##   0  on success
##   1  on error (missing arg, no commits, invalid action, zero picks)
pick-commits-to-squash() {
  local BASE_BRANCH="$1"

  if [ -z "$BASE_BRANCH" ]; then
    echo "[ERR]: pick-commits-to-squash requires a base branch as the first argument" >&2
    return 1
  fi

  # Collect all commits on the current branch that are not in $BASE_BRANCH
  # (oldest first, so the squashing order matches what the user will see)
  local -a HASHES
  local -a MESSAGES
  while IFS=$'\t' read -r hash msg; do
    HASHES+=("$hash")
    MESSAGES+=("$msg")
  done < <(git log --reverse --pretty=format:"%H%x09%s" "${BASE_BRANCH}..HEAD")

  if [ ${#HASHES[@]} -eq 0 ]; then
    echo "[ERR]: No commits found between current branch and '$BASE_BRANCH'. Nothing to squash." >&2
    return 1
  fi

  echo ""
  echo "  Decide what to do with each commit (oldest first). Defaults in [brackets]."
  echo "    [p]ick    = keep this commit as-is"
  echo "    [s]quash  = merge this commit into the previous one"
  echo "    [d]rop    = remove this commit entirely"
  echo ""

  local -a ACTIONS
  for i in $(seq 1 "${#HASHES[@]}"); do
    local ACTION
    local short_hash="${HASHES[$((i-1))]:0:7}"
    if [ "$i" -eq 1 ]; then
      # First commit must be 'pick' (cannot squash the very first one)
      echo "  ───────────────────────────────────────────────"
      echo "  → [$i] ${short_hash}  ${MESSAGES[$((i-1))]}"
      echo "      Action: pick (required, first commit)"
      echo "  ───────────────────────────────────────────────"
      ACTION="pick"
    else
      local DEFAULT_ACTION="s"
      echo "  ───────────────────────────────────────────────"
      echo "  → [$i] ${short_hash}  ${MESSAGES[$((i-1))]}"
      read -p "      Action: [p]ick/[s]quash/[d]rop? [$DEFAULT_ACTION]: " ACTION
      ACTION=${ACTION:-$DEFAULT_ACTION}
      case "$ACTION" in
        p|P) ACTION="pick"   ;;
        s|S) ACTION="squash" ;;
        d|D) ACTION="drop"   ;;
        *)
          echo "[ERR]: Invalid action '$ACTION'. Use p/s/d." >&2
          return 1
          ;;
      esac
    fi
    ACTIONS+=("$ACTION")
  done
  echo "  ───────────────────────────────────────────────"
  echo ""

  # Validate: at least one commit must be 'pick'
  local PICK_COUNT=0
  for action in "${ACTIONS[@]}"; do
    if [ "$action" = "pick" ]; then
      PICK_COUNT=$((PICK_COUNT + 1))
    fi
  done

  if [ "$PICK_COUNT" -eq 0 ]; then
    echo "[ERR]: Need at least one commit marked as 'pick'" >&2
    return 1
  fi

  # Expose results to the caller via globals (assigned without `local` on purpose)
  PICKED_HASHES=("${HASHES[@]}")
  PICKED_MESSAGES=("${MESSAGES[@]}")
  PICKED_ACTIONS=("${ACTIONS[@]}")
  PICKED_COUNT=${#HASHES[@]}
}

git-squash() {

  # refuse to run if there are uncommitted changes (rebase needs a clean tree)
  git-check-working-tree-clean || return 1

  ## Getting the current branch name
  local CURRENT_BRANCH
  CURRENT_BRANCH=$(git branch --show-current)

  # Resolve the base branch (delegated; also handles detached HEAD + invalid arg)
  local BASE_BRANCH
  BASE_BRANCH=$(git-base-branch "main") || return 1

  echo "-----------------------------------------------------------------------------"
  echo "  GIT  Squash Commits  ------------------------------------------------------"
  echo "-----------------------------------------------------------------------------"
  echo "[CURRENT BRANCH] - $CURRENT_BRANCH"
  echo "[BASE BRANCH] - $BASE_BRANCH"
  echo "-----------------------------------------------------------------------------"

  ## Getting the branch that we are comparing to
  get-branch-commits "$BASE_BRANCH"

  ## Now we have this function to pick all the commits to squash
  # pick-commits-to-squash "$BASE_BRANCH"
}