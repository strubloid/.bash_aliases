#!/bin/bash

# Strubloid::general::react

## react js commands
react-create(){

  if [ -z "$1" ]
    then
        npx create-react-app .
    else
        npx create-react-app . $1
  fi
}

react-install-sass(){

  # you must install the node-saas package
  npm install node-sass --save

  # Renaming the App.css or creating a new App.scss
  APPCSS="src/App.css";
  if [ -f ${APPCSS} ]; then
    mv $APPCSS src/App.scss
  else
    touch src/App.scss
  fi


}