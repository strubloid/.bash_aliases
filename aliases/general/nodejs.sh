#!/bin/bash

# Strubloid::general::nodejs

## node js commands
# cleaning the node cache
alias npm-clean="npm cache clean --force"

# adding the minimum dependencies
alias node-i-step1="npm i express mongoose ejs"

## adding dev dependencies
alias node-i-step2="npm i --save-dev nodemon node-sass dotenv"

## this will start the node dev environment
alias nd-start="npm run devStart"

alias nd-package-update="npm install && npm install --safe-dev"

## This is to remove the necessity of run with sudo a local project
alias fix-local-npm="sudo chown -R $(whoami) node_modules/"

basic-node-scrapper()
{
  echoHeader "[Basic Node Scrapper]: "

  # starting the NPM project in the current folder
  echoLine "[]: Starting the project: npm init -y"
  npm init -y

  # installing the minimum dependency for this project have scrapper ability
  echoLine "[]: Installation of basic node modules"
  npm install axios cheerio puppeteer --save

  # installing the dev tools
  echoLine "[]: Installation of the dev node modules"
  npm install nodemon --save-dev

  # copying the .gitgnore basic file
  GITIGNOREFILE=$BASH_ALIASES_PROJECT_FOLDER/import/node/.gitignore
  EXISTGITGNORE=$(pwd)/.gitignore

  if [ ! -f $EXISTGITGNORE ]
  then
    echoLine "[]: Copying $BASH_ALIASES_PROJECT_FOLDER/import/node/.gitignore"
    cp "$BASH_ALIASES_PROJECT_FOLDER/import/node/.gitignore" .
  else
    echoLine "[]: Exist already .gitgnore file in the $(pwd)"
  fi

}
