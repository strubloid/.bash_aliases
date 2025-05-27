#!/bin/bash

# Strubloid::general::git

# git aliases
alias git-revert="git clean -d -f -f"
alias gitup-master="git checkout master && git pull origin master && git fetch --all"

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

    printf "Message (Mandatory):\n[]: "
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