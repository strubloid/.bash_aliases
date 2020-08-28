#!/bin/bash

# Strubloid::general::heroku

alias heroku-login="heroku login"
alias heroku-login-shell="heroku login --interactive"

# Adding a heroku repository to the current git project
heroku-add-repository() {
  heroku git:remote -a "$1"
}

# Basic steps to install heroku on ubuntu
heroku-install() {
  sudo snap install --classic heroku
}


create-heroku-nodejs-project() {


  if [ -n "$1" ]; then
    git clone https://github.com/mars/heroku-cra-node.git $1 && \
    cd $1 && \
    rm -rf LICENSE README.md .git .gitignore && \
    rm package.json



  else
    echo "You must specify the project name\n"
  fi


}
