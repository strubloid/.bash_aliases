#!/bin/bash

# Strubloid::general::heroku

alias heroku-login="heroku login"
alias heroku-login-shell="heroku login --interactive"

# Adding a heroku repository to the current git project
heroku-add-repository()
{
  heroku git:remote -a "$1"
}

# Basic steps to install heroku on ubuntu
heroku-install()
{
  sudo snap install --classic heroku
}