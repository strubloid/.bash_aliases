#!/bin/bash

# Strubloid::general::express

express-api-netlify() {

    ## reference https://css-tricks.com/building-serverless-graphql-api-in-node-with-express-and-netlify/
    printf "[Express API on Netlify]: \n"

    # starting the NPM project in the current folder
    printf "[]: Starting the project\n"
    npm init -y

    # installing the minimum dependency for this project have scrapper ability
    printf "[]: Main Modules\n"
    npm i express express-graphql graphql body-parser serverless-http

    printf "[]: Installing Netlify\n"
    npm i -g netlify-cli

    printf "[?] Do you want  to install Puppeteer?\n[Y or N]: "
    read withPuppeteer
    if [ "$withPuppeteer" == "Y" ] || [ "$withPuppeteer" == "y" ]; then
        npm install npm install puppeteer --save
    fi

    # installing the dev tools
    printf "[]: Installation of the dev node modules\n"
    npm install nodemon --save-dev

    # copying the a basic .gitgnore
    EXISTGITGNORE=$(pwd)/.gitignore
    if [ ! -f $EXISTGITGNORE ]; then
        printf "[]: Copying $BASH_ALIASES_PROJECT_FOLDER/import/node/.gitignore\n"
        cp "$BASH_ALIASES_PROJECT_FOLDER/import/node/.gitignore" .
    else
        printf "[]: Exist already .gitgnore file in the $(pwd)\n"
    fi

    # copying the a basic Server.js
    EXISTENV=$(pwd)/.env

    if [ ! -f $EXISTENV ]; then
        printf "[]: Copying $BASH_ALIASES_PROJECT_FOLDER/import/node/.env\n"
        cp "$BASH_ALIASES_PROJECT_FOLDER/import/node/.env" .
    else
        printf "[]: Exist already .env file in the $(pwd)\n"
    fi

    # copying the a basic Server.js
    EXISTNETLIFY=$(pwd)/netlify.toml

    if [ ! -f $EXISTNETLIFY ]; then
        printf "[]: Copying $BASH_ALIASES_PROJECT_FOLDER/import/node/netlify.toml\n"
        cp "$BASH_ALIASES_PROJECT_FOLDER/import/node/netlify.toml" .
    else
        printf "[]: Exist already netlify.toml file in the $(pwd)\n"
    fi

}
