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

heroku-node-new()
{
  if [ -n "$1" ]; then

    npx create-react-app $1
    cd $1

    gitignore=$BASH_ALIASES_PROJECT_FOLDER/import/.gitignore
    echo -e "[]: Copying $gitignore"
    cp "$gitignore" .

    until read -r -p "Git URL (Mandatory): " gitrepositoryurl && test "$gitrepositoryurl" != ""; do
      continue
    done

    printf "Git URL: $gitrepositoryurl\n"
    git remote add origin $gitrepositoryurl
    git branch -M master
    git push -u origin master
    git add .
    git commit -m "Starting new project: $1"
    git push origin master


  else

    echo "You must specify the project name\n"
  fi
}


#create-heroku-nodejs-project() {
#
#  if [ -n "$1" ]; then
#    git clone https://github.com/mars/heroku-cra-node.git $1
#    cd $1
#    rm -rf LICENSE README.md .git .gitignore
#    rm package.json
#    rm package-lock.json
#
#    # creating a variable just to store where is the package.json
#    PACKAGEJSON=$BASH_ALIASES_PROJECT_FOLDER/import/package.json
#
#    echo -e "[]: Copying $PACKAGEJSON"
#    cp "$PACKAGEJSON" .
#
#    perl -i -pe 's/"\[app-name\]"/"'$1'"/g' $PACKAGEJSON
#
#    # git push heroku master
#    # heroku buildpacks
#    # heroku config:set JS_RUNTIME_TARGET_BUNDLE='/app/react-ui/build/static/js/*.js'
#    # git commit --allow-empty -m 'Enable runtime config with create-react-app-inner-buildpack'
#    # git push heroku master
#
#  else
#
#    echo "You must specify the project name\n"
#  fi
#
#}
