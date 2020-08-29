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
#  npm install node-sass --save

  # Renaming the App.css or creating a new App.scss
  AppCss="src/App.css";
  AppScss="src/App.scss";

  if [ -f ${AppCss} ]; then
    mv $AppCss $AppScss
  else
      if [ ! -f ${AppScss} ]; then

        # create the file
        touch src/App.scss

        # Copy to the src/App.scss base file
        ImportAppScss=$BASH_ALIASES_PROJECT_FOLDER/import/App.scss
        echo -e "[]: Copying $ImportAppScss"
        cp "$ImportAppScss" $AppScss
      else
        echo -e "[]: you have it already, moving on!"
      fi
  fi



}