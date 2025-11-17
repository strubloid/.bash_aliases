#!/bin/bash

# Strubloid::general::heroku

alias heroku-login="heroku login"
alias heroku-login-shell="heroku login --interactive"

# Adding a heroku repository to the current git project
# example: heroku-add-repository strubloid <- this is the name of the repo only!
heroku-add-repository() {
  heroku git:remote -a "$1"
}

# this will purge the cache on the server
heroku-server-clean(){
  heroku repo:purge_cache -a $1
}

# Install heroku via curl
heroku-curl-installation(){
  curl https://cli-assets.heroku.com/install-ubuntu.sh | sh
}

# Basic steps to install heroku on ubuntu
heroku-install() {
  sudo snap install --classic heroku
}

heroku-node-new() {
  if [ -n "$1" ]; then

        npx create-react-app $1
        cd $1

        gitignore=$BASH_ALIASES_PROJECT_FOLDER/import/node/.gitignore
        echo -e "* Copying $gitignore"
        cp "$gitignore" .

          until read -r -p "Git URL (Mandatory): " gitrepositoryurl && test "$gitrepositoryurl" != ""; do
            continue
          done

        printf "Git URL: $gitrepositoryurl\n"
        git remote add origin $gitrepositoryurl
        git branch -M master
        git add .
        rm README.md
        git commit -m "Starting new project: $1"
        git push origin master

    # creating a variable just to store where is the Server.js
    SERVERJS=$BASH_ALIASES_PROJECT_FOLDER/import/Server.js

    echo -e "* Copying $SERVERJS"
    cp "$SERVERJS" .

    # configuring the express for the Server.js
    npm add express express-favicon path
    perl -i -pe 's/"start": "react-scripts start"/"start": "node server.js"/g' package.json
    git add . && git commit -m "Adding the express for the Server.js" && git push origin master

    heroku-login

    until read -r -p "Heroku Repository Name (Mandatory): " herokuRepositoryName && test "$herokuRepositoryName" != ""; do
      continue
    done

    heroku-add-repository $herokuRepositoryName

  else
    echo "You must specify the project name\n"
  fi
}

hp(){
  gitpush && git push heroku master
}