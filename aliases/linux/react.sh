#!/bin/bash

# Strubloid::general::react


## react js commands
react-create() {
  if [ -z "$1" ]; then
    npx create-react-app .
  else
    npx create-react-app "$1"
  fi
}

## this will create with nextjs in it
react-create-next() {
  if [ -z "$1" ]; then
    npx create-next-app@latest .
  else
    npx create-next-app@latest "$1"
  fi
}

install-and-configure-jest(){
  local IS_NEXT=$1

  npm i -D jest ts-jest @types/jest @testing-library/react @testing-library/jest-dom jest-environment-jsdom ts-node


}

starting-new-react-environment() {
  echo -e "* Starting a new react environment"

  read -p "NextJS website? (y/n) " -n 1 -r
  echo

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    IS_NEXT=true
    react-create-next
  else
    IS_NEXT=false
    react-create
  fi

  # Ask about Jest
  read -p "Install and configure Jest? (y/n) " -n 1 -r
  echo

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    install-and-configure-jest $IS_NEXT
  fi
}


react-install-sass(){

  # you must install the node-sass package
#  npm install node-sass --save

  # Renaming the App.css or creating a new App.scss
  AppCss="src/App.css";
  AppScss="src/App.scss";

  if [ -f ${AppCss} ]; then
    mv $AppCss $AppScss
  else
      if [ ! -f ${AppScss} ]; then

        # create the file
        touch $AppCss

        # Copy to the src/App.scss base file
        ImportAppScss=$BASH_ALIASES_PROJECT_FOLDER/import/App.scss
        echo -e "* Copying $ImportAppScss"
        cp "$ImportAppScss" $AppScss

      else
        echo -e "[$AppScss]: you have it already, moving on!"
      fi
  fi

  # guarantee that we have binary folder
  binaryFolder="bin"
  if [ ! -d $binaryFolder ]; then
    echo -e "* Creating $ImportAppScss"
    mkdir $binaryFolder
  else
    echo -e "[$binaryFolder]: you have the binary folder already, moving on!"
  fi

  # Copying basic binaries for sass execution
  projectBuildCssFile="bin/build-css"
  if [ ! -f $projectBuildCssFile ]; then
    ImportBuildCss=$BASH_ALIASES_PROJECT_FOLDER/import/sass/bin/build-css
    echo -e "* Copying $ImportBuildCss"
    cp  "$ImportBuildCss" $projectBuildCssFile
  else
      echo -e "[$projectBuildCssFile]: you have it already, moving on!"
  fi

  projectWatchCssFile="bin/watch-css"
  if [ ! -f $projectWatchCssFile ]; then
    ImportWatchCss=$BASH_ALIASES_PROJECT_FOLDER/import/sass/bin/watch-css
    echo -e "* Copying $ImportWatchCss"
    cp  "$ImportWatchCss" $projectWatchCssFile
  else
      echo -e "[$projectWatchCssFile]: you have it already, moving on!"
  fi

  # Replacing the import in the src/App.js
  srcApp="src/App.js";
  existSrcApp=$(checkInFile "App.scss" "$srcApp")
  if [ $existSrcApp != 'error' ] && [ $existSrcApp != "0" ]; then
    echo -e "[App.sccs]: you have it already, moving on!"
  else
    regexSearch="import.*App.css'"
    regexReplace="import '.\/App.scss'"
    changeInFile "$regexSearch" "$regexReplace" "$srcApp"
    echo -e "* Changing the $srcApp to have App.scss in it"
  fi

  packageJson="package.json";
  existPackageJson=$(checkInFile "build-css" "$packageJson")
  if [ $existPackageJson != 'error' ] && [ $existPackageJson != "0" ]; then
    echo -e "[build-css]: you have it already, moving on!"
  else
    buildCssLine='    "build-css": "./bin/build-css",'
    buildWatchLine='    "watch-css": "./bin/watch-css",'
    echo -e "* Adding lines\n$buildCssLine\n$buildWatchLine"

    # Searching for the patter node serve.js to add binaries
    PACKAGEJSONUPDATED=$(awk -v pattern=".*node server.js" \
        -v line1="$buildCssLine"  -v line2="$buildWatchLine" \
        "\$0 ~ pattern {print line1; print line2; print; next;} 1" "$packageJson")

    echo -e "$PACKAGEJSONUPDATED" > "$packageJson"


  fi

}