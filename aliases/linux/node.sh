## https://www.freecodecamp.org/news/how-to-enable-es6-and-beyond-syntax-with-node-and-express-68d3e11fe1ab/
node-express-es6-babel-basic()
{

#    until read -r -p "Project Name (Mandatory): " projectName && test "$projectName" != "";
#    do
#        continue
#    done
#
#    cd ..  \
#    && npx express-generator "$projectName" --no-view \
#    && cd "$projectName" \
#    && npm install

#    mkdir server \
#    && mv -f bin server/ \
#    && mv -f routes server/ \
#    && mv app.js server/

#    mv server/bin/www server/bin/www.js
#    perl -i -pe 's/"node \.\/bin\/www"/"node \.\/server\/bin\/www"/g' package.json

    # Replacing the script server command
#    stringFind='\"start\": \"node \.\/bin\/www\"'
#    stringReplace='\"server\": \"node \.\/server\/bin\/www\"'
#    command="s/$stringFind/$stringReplace/g"
#    perl -i -pe "$command" package.json

    # Configuring the www.js file
    if [ -z "$projectName" ]; then
        projectName='job-search'
    fi

#    perl -i -pe "s/var app \= require\('\.\.\/app'\)/import app from '\.\.\/app'/g" server/bin/www.js
#    debugLine="import debugLib from 'debug';\nconst debug = debugLib\('$projectName:server'\)"
#    perl -i -pe "s/var debug \= require\('debug'\)\('.*:server'\)/$debugLine/g" server/bin/www.js
#    perl -i -pe "s/var http \= require\('http'\)/import http from 'http'/g" server/bin/www.js

    # Configuration for routers
#    expressSearch="var express \= require\('express'\)"
#    expressReplace="import express from 'express'"
#    moduleExportsRouterSearch="module.exports = router"
#    moduleExportsRouterReplace="export default router"
#
#    perl -i -pe "s/$expressSearch/$expressReplace/g" server/routes/index.js
#    perl -i -pe "s/$moduleExportsRouterSearch/$moduleExportsRouterReplace/g" server/routes/index.js
#
#    perl -i -pe "s/$expressSearch/$expressReplace/g" server/routes/users.js
#    perl -i -pe "s/$moduleExportsRouterSearch/$moduleExportsRouterReplace/g" server/routes/users.js

    # Configuring app.js
#    perl -i -pe "s/$expressSearch/$expressReplace/g" server/app.js
#    perl -i -pe "s/var path \= require\('path'\)/import path from 'path'/g" server/app.js
#    perl -i -pe "s/var cookieParser \= require\('cookie-parser'\)/import cookieParser from 'cookie-parser'/g" server/app.js
#    perl -i -pe "s/var logger \= require\('morgan'\)/import logger from 'morgan'/g" server/app.js
#
#    indexRouterFind="var indexRouter \= require\('\.\/routes\/index'\)"
#    indexRouterReplace="import indexRouter from '\.\/routes\/index'"
#    perl -i -pe "s/$indexRouterFind/$indexRouterReplace/g" server/app.js
#
#    usersRouterFind="var usersRouter \= require\('\.\/routes\/users'\)"
#    usersRouterReplace="import usersRouter from '\.\/routes\/users'"
#    perl -i -pe "s/$usersRouterFind/$usersRouterReplace/g" server/app.js
#
#    expressStaticSearch="express.static\(path\.join\(__dirname, 'public'\)\)"
#    expressStaticReplace="express.static\(path\.join\(__dirname, '\.\.\/public'\)\)"
#    perl -i -pe "s/$expressStaticSearch/$expressStaticReplace/g" server/app.js
#
#    perl -i -pe "s/module.exports = app/export default app/g" server/app.js

    ## in case to run this on windows we had to add npm-run-all
#    npm install --save npm-run-all

    ## Installation of basic dependencies
#    npm install --save @babel/core @babel/cli @babel/preset-env nodemon rimraf

    # Searching for a place to add babel
#    dependenciesSearch="\"dependencies\": \{"
#    dependenciesReplace="\"babel\": \{\n\t\"presets\": \[\"\@babel\/preset-env\"\]\n  \},\n  \"dependencies\": \{"
#    perl -i -pe "s/$dependenciesSearch/$dependenciesReplace/g" package.json

    # Adding transpile
    scriptsStartSearch="\"scripts\": \{"
#    scriptsStartReplace="$scriptsStartSearch\n\t\"transpile\": \"babel \.\/server --out-dir dist-server\","
#    perl -i -pe "s/$scriptsStartSearch/$scriptsStartReplace/g" package.json

    # Running for the first time the transpile
#    npm run transpile

#    cleanStartReplace="$scriptsStartSearch\n\t\"clean\": \"rimraf dist-server\","
#    perl -i -pe "s/$scriptsStartSearch/$cleanStartReplace/g" package.json

    ## adding build and dev instances
#    buildReplace='"build": "npm-run-all clean transpile",'
#    devReplace='"dev": "NODE_ENV=development npm-run-all build server",'
#    buildDevReplace="$scriptsStartSearch\n\t$buildReplace\n\t$devReplace"
#    perl -i -pe "s/$scriptsStartSearch/$buildDevReplace/g" package.json

    ## Adding prod instances
#    prodStartReplace='"start": "npm run prod",'
#    prodRunReplace='"prod": "NODE_ENV=production npm-run-all build server",'
#    buildDevReplace="$scriptsStartSearch\n\t$prodStartReplace\n\t$prodRunReplace"
#    perl -i -pe "s/$scriptsStartSearch/$buildDevReplace/g" package.json

    ## Replace of the correct file to run
#    serverFind='\"server\": \"node \.\/server\/bin\/www\"'
#    serverReplace='\"server\": "node \.\/dist-server\/bin\/www"'
#    perl -i -pe "s/$serverFind/$serverReplace/g" package.json

    # Adding the nodemon
#    nodemonReplace="$scriptsStartSearch\n\t\"watch:dev\": \"nodemon\","
#    perl -i -pe "s/$scriptsStartSearch/$nodemonReplace/g" package.json
#nodemonConf=$(cat << END
#"nodemonConfig": {
#  "exec": "npm run dev",
#  "watch": ["server/*", "public/*"],
#  "ignore": ["**/__tests__/**", "*.test.js", "*.spec.js"]
#},
#END
#)

nodemonConf=$(cat << END
\"nodemonConfig\": \{
\t\"exec\": \"npm run dev\",
\t\"watch\": \["server\/\*\", \"public\/\*\"\],
\t\"ignore\": \[\"\*\*\/__tests__\/\*\*\", \"\*.test.js\", \"\*.spec.js\"\]
  \}
END
)
    nodemonTagReplace="$nodemonConf,\n  $scriptsStartSearch"
    perl -i -pe "s/$scriptsStartSearch/$nodemonTagReplace/g" package.json


}