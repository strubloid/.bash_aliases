#!/bin/bash

# Strubloid::general::angular

basic-angular-app()
{
    # reference: https://www.youtube.com/watch?v=1tRLveSyNz8
    npm install -g @angular/cli
}

basic-node-API() {
    ## reference https://www.callicoder.com/node-js-express-mongodb-restful-crud-api-tutorial/
    printf "[Basic Angular]: \n"

    # starting the NPM project in the current folder
    printf "[]: Starting the project: npm init -y\n"
    npm init -y

    # installing the minimum dependency for this project have scrapper ability
    printf "[]: Installation of basic node modules\n"
    npm install npm install express body-parser mongoose --save

    printf "[?] Do you want  to install Puppeteer?\n[Y or N]: "
    read withPuppeteer
    if [ "$withPuppeteer" == "Y" ] || [ "$withPuppeteer" == "y" ]; then
        npm install npm install puppeteer --save
    fi

    # installing the dev tools
    printf "[]: Installation of the dev node modules"
    npm install nodemon --save-dev

    # copying the a basic .gitgnore
    EXISTGITGNORE=$(pwd)/.gitignore
    if [ ! -f $EXISTGITGNORE ]; then
        printf "[]: Copying $BASH_ALIASES_PROJECT_FOLDER/import/node/.gitignore"
        cp "$BASH_ALIASES_PROJECT_FOLDER/import/node/.gitignore" .
    else
        printf "[]: Exist already .gitgnore file in the $(pwd)"
    fi

    # copying the a basic Server.js
    EXISTSERVERJS=$(pwd)/Server.js

    if [ ! -f $EXISTSERVERJS ]; then
        printf "[]: Copying $BASH_ALIASES_PROJECT_FOLDER/import/node/api-express-mongo-server.js"
        cp "$BASH_ALIASES_PROJECT_FOLDER/import/node/api-express-mongo-server.js" "Server.js"
    else
        printf "[]: Exist already Server.js file in the $(pwd)"
    fi

    # copying the a basic Server.js
    EXISTENV=$(pwd)/.env

    if [ ! -f $EXISTENV ]; then
        printf "[]: Copying $BASH_ALIASES_PROJECT_FOLDER/import/node/.env\n"
        cp "$BASH_ALIASES_PROJECT_FOLDER/import/node/.env" .
    else
        printf "[]: Exist already .env file in the $(pwd)"
    fi

}
