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

## This will configure the jest
install-and-configure-jest() {
  
  local IS_NEXT=$1
  echo "* Installing Jest dependencies..."
  
  npm i -D jest ts-jest @types/jest @testing-library/react @testing-library/jest-dom jest-environment-jsdom ts-node

  if [ "$IS_NEXT" = true ]; then
    echo "* Writing jest.config.ts..."
    cat > jest.config.ts << 'EOF'
import type { Config } from 'jest'
import nextJest from 'next/jest.js'

const createJestConfig = nextJest({ dir: './' })

const config: Config = {
  coverageProvider: 'v8',
  testEnvironment: 'jsdom',
  setupFilesAfterFramework: ['<rootDir>/jest.setup.ts'],
}

export default createJestConfig(config)
EOF

  else
    echo "* Writing jest.config.ts..."
    cat > jest.config.ts << 'EOF'
import type { Config } from 'jest'

const config: Config = {
  testEnvironment: 'jsdom',
  setupFilesAfterFramework: ['<rootDir>/jest.setup.ts'],
  transform: {
    '^.+\\.(ts|tsx)$': 'ts-jest',
  },
}

export default config
EOF
  fi

  echo "* Writing jest.setup.ts..."
  cat > jest.setup.ts << 'EOF'
import '@testing-library/jest-dom'
EOF

  echo "* Adding test scripts to package.json..."
  npx json -I -f package.json \
    -e 'this.scripts.test="jest"' \
    -e 'this.scripts["test:watch"]="jest --watch"' \
    -e 'this.scripts["test:coverage"]="jest --coverage"'

  echo "* Jest configured successfully!"
}

## This will install styled-components and its types.
installing-styled-components() {
  echo "* Installing styled-components and its types..."
  npm i styled-components @types/styled-components
}

## This will add @components/* path alias to tsconfig.json and jest.config.ts
configure-component-folder() {
  local COMPONENT_DIR="${1:-app/components}"
  local TSCONFIG="tsconfig.json"
  local JEST_CONFIG="jest.config.ts"

  # Update tsconfig.json
  if [ -f "$TSCONFIG" ]; then
    echo "* Updating $TSCONFIG..."
    if grep -q '"@components/\*"' "$TSCONFIG"; then
      echo "  [@components/*]: already configured in $TSCONFIG, skipping..."
    else
      sed -i \
        -e '/"@\/\*":/ s/\]$/\],/' \
        -e '/"@\/\*":/a\            "@components\/*": [".\/'"$COMPONENT_DIR"'\/*"]' \
        "$TSCONFIG"
      echo "  Added @components/* to $TSCONFIG"
    fi
  else
    echo "  [$TSCONFIG]: not found, skipping..."
  fi

  # Update jest.config.ts
  if [ -f "$JEST_CONFIG" ]; then
    echo "* Updating $JEST_CONFIG..."
    if grep -q '"^@components/' "$JEST_CONFIG"; then
      echo "  [@components]: already configured in $JEST_CONFIG, skipping..."
    else
      sed -i '\|"^@/|i\        "^@components/(.*)$": "<rootDir>/'"$COMPONENT_DIR"'/$1",' "$JEST_CONFIG"
      echo "  Added @components mapper to $JEST_CONFIG"
    fi
  else
    echo "  [$JEST_CONFIG]: not found, skipping..."
  fi

  echo "* Component folder configured successfully!"
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

  ## adding styling with styled-components
  installing-styled-components

  ## adding @components/* path alias
  configure-component-folder
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