#!/bin/bash

# Strubloid::general::nodejs

## node js commands

# adding the minimum dependencies
alias node-i-step1="npm i express mongoose ejs"

## adding dev dependencies
alias node-i-step2="npm i --save-dev nodemon dotenv"

## this will start the node dev environment
alias nd-start="npm run devStart"

## This is to remove the necessity of run with sudo a local project
alias fix-local-npm="sudo chown -R $(whoami) node_modules/"

basic-node-scrapper()
{
  # starting the NPM project in the current folder
  npm init -y

  # installing the minimum dependency for this project have scrapper ability
  npm install axios cheerio puppeteer --save

  # installing the dev tools
  npm install nodemon --save-dev
}