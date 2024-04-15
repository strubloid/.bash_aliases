#!/bin/bash

# Strubloid::linux::git

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

# This will update the develop branch
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