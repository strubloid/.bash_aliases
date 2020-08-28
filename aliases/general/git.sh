#!/bin/bash

# Strubloid::general::git

# git aliases
alias git-revert="git clean -d -f -f"
alias gitup-master="git checkout master && git pull origin master && git fetch --all"

# git basic commands
alias gc="git commit -m"
alias gs="git status"

# tags
alias gt-tag-c="git tag "

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

hp(){

  gitpush && git push heroku master
}