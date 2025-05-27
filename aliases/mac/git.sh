#!/bin/zsh

# Strubloid::linux::git

# Protected branches that should not be automatically deleted
PROTECTED_BRANCHES="main|master|dev"

# git aliases
alias git-revert="git clean -d -f -f"

# This will remove all the branches that are merged with master
# and not the master or develop branches
git-clean-merged(){
  git branch --merged | egrep -v "(^\*|$PROTECTED_BRANCHES)" | xargs git branch -d
}

# This will remove all the branches that are unmerged with master
# and not the master or develop branches
git-clean-unmerged()
{
  git branch --no-merged | egrep -v "(^\*|$PROTECTED_BRANCHES)" | xargs git branch -D
}

# This will remove all the branches that are not merged with master
# and not the master or develop branches
git-clean-all()
{
  git branch | egrep -v "(^\*|$PROTECTED_BRANCHES)" | xargs git branch -D
}

# This will update the master branch
# it will checkout the master branch, pull the latest changes
# and checkout the current branch again
git-update-master() {
  printf "[MASTER] - "
  git checkout master -q && git pull origin master -q  && git checkout . -q
  printf "OK\n"
}

# This will update the develop branch
# it will checkout the develop branch, pull the latest changes
# and checkout the current branch again
git-update-develop() {
  printf "[DEVELOP] - "
  git checkout develop -q && git pull origin develop -q && git checkout . -q
  printf "OK\n"
}

# This will update the main branch
# it will checkout the main branch, pull the latest changes
# and checkout the current branch again
git-update-main() {
  printf "[MAIN] - "
  git checkout main -q && git pull origin main -q && git checkout . -q
  printf "OK\n"
}

# This will update the release branch
# it will checkout the release branch, pull the latest changes
# and checkout the current branch again
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
      echo -n "[Commit Message]: "
      read COMMIT_MESSAGE
  else
      # mounting the commit message in the format that jira accepts
      COMMIT_MESSAGE="$1"
  fi

  # Loading should update the base code
  if [ -z "$2" ]
  then
      echo -n "Update Master/Develop [y/n] : "
      read UPDATE_MASTER_DEVELOPER
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
      echo -n "[Commit Message]: "
      read COMMIT_MESSAGE
  else
      # mounting the commit message in the format that jira accepts
      COMMIT_MESSAGE="$1"
  fi

  # Loading should update the base code
  if [ -z "$2" ]
  then
      echo -n "Update Main [y/n] : "
      read UPDATE_MAIN
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
      echo -n "[Commit Message]: "
      read COMMIT_MESSAGE
  else
      # mounting the commit message in the format that jira accepts
      COMMIT_MESSAGE="$1"
  fi

  commit-update-git "$COMMIT_MESSAGE" "No"

}

commit-main() {

  # Loading the commit message
  if [ -z "$1" ]
  then
      echo -n "[Commit Message]: "
      read COMMIT_MESSAGE
  else
      # mounting the commit message in the format that jira accepts
      COMMIT_MESSAGE="$1"
  fi

  commit-update-master-git "$COMMIT_MESSAGE" "No"

}

# This will commit in git and push the code
commit ()
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
  echo -n "can we continue? [y/N]"
  read canContinue

  ## this will start only if a user is ok about what is the branch
  ## to revert
  if [[ "$canContinue" =~ ^(yes|y|Y|Yes|YES)$ ]]
  then

    # Loading the commit message
    if [ -z "$1" ]
    then
        echo -n "[Branch ID]: "
        read GIT_BRANCH_REFERENCE
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
      echo -n "[Destination Folder]: "
      read GIT_STATUS_DESTINATION_FOLDER
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
      #  mkdir -p -q "$FOLDER_STRUCTURE_TO_REPLICATE"

      ## copy over the file to the destination
      cp "$file" "$FOLDER_STRUCTURE_TO_REPLICATE"

    # echo "Copied $file to $FOLDER_STRUCTURE_TO_REPLICATE"

    # Debug area
    # echo -n "[Continue ?]: "
    # read CONTINUE_PROCESS
    # if [[ "$CONTINUE_PROCESS" =~ [nN](o)?$ ]]; then
    #   break
    # fi

  done

}

# A correct way to remove a hotfix branch on localhost after merged with master branch by a code reviewer
gitflow-clean-hotfix()
{
    echo -n "Hotfix Branch Name: "
    read hotfixBranchName
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
    echo -n "Feature Branch Name: "
    read featureBranchName
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
            echo -n "Message : "
            read message
            echo -n "Tag Name : "
            read tag
            echo -n "Git Hash : "
            read hash

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
            echo -n "Tag Name to delete : "
            read tag
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
    echo -n "What is the file to remove from git status? "
    read fileToRemoveFromGitStatus

    ## Making sure that the file exist before remove from the git status
    while [ ! -f "$fileToRemoveFromGitStatus" ]; do
        echo "[$fileToRemoveFromGitStatus]: does not exist"
        echo -n "What is the file to remove from git status? "
        read fileToRemoveFromGitStatus
    done
  else
    fileToRemoveFromGitStatus="$1"
  fi

  # This will run the removal of the file
  git update-index --assume-unchanged "$fileToRemoveFromGitStatus"

}
