#!/bin/bash
SOURCE=$(dirname "$(readlink -f "$0")")
PROJECTSSOURCE='~/Projects/'


# Method that will run docker command in php container
moma-dk-php-exec()
{
    if [ -z "$2" ]
    then
        docker-compose exec php sh -c "$1"
    else
        docker-compose exec php sh -c "$1 $2"
    fi
}

# Method that will run a docker command in database container
moma-dk-db-exec()
{
    while getopts u:p:h:f:o: option
    do
     case "${option}"
     in
     u) DBUSER=${OPTARG};;
     p) DBPASSWORD=${OPTARG};;
     h) DBHOST=${OPTARG};;
     f) FILE=${OPTARG};;
     o) OUTPUT=${OPTARG};;
     esac
    done

    if [ -z "$DBUSER" ]
    then
       DBUSER='root'
    fi

    if [ -z "$DBPASSWORD" ]
    then
        DBPASSWORD='root'
    fi

    if [ -z "$DBHOST" ]
    then
        DBHOST='database'
    fi

    if [ -z "$FILE" ]
    then
        FILE='.docker/run.sql'
    fi

    if [ -z "$OUTPUT" ]
    then
        OUTPUT='result.sql'
    fi

    echo "User:"$DBUSER
    echo "Password:"$DBPASSWORD
    echo "Host:"$DBHOST
    echo "File:"$FILE
    echo "Otput:"$OUTPUT

    docker-compose exec php sh -c "mysql -h $DBHOST -u $DBUSER -p$DBPASSWORD < $FILE" > $OUTPUT

}

## Method that will import a database
moma-dk-db-import()
{
   ## Build this later
   #  gzip -dc /home/strubloid/dbdumps/woodies-20191112.sql.gz | sed -e 's/DEFINER=`.*`@`.*`/DEFINER=`root`@`localhost`/g' | pv | docker-compose exec -T database mysql -uroot -proot livesanitized
   echo 'isnt implemented yet';
}

moma-dk-gulp-generate()
{

    moma-dk-php-exec npm i;
    moma-dk-php-exec npm run build;
#    alias mothercare-css-generate="docker-compose exec php npm i &&
#    docker-compose exec php npm run build"
}

moma-dk-gulp-watch()
{
#    alias mothercare-css-watch="docker-compose exec php npm i && docker-compose exec php npm run watch"
     echo 'isnt implemented yet';
}

## TODO: Fix this source import
# Loading magento 1 moma items
#source "${SOURCE}/aliases/general/magento.sh"

# Method that will check what is the magento version
moma-magento-version()
{
    moma-dk-php-exec "bin/magento --version"
}

# Method that will check what is the status of the modules in the project
moma-module-check()
{
    moma-dk-php-exec "bin/magento module:status"
}

# Method that will reindex all indexes
moma-reindex()
{
    moma-dk-php-exec "bin/magento indexer:reindex"
}

# Method that will run the setup upgrade 
moma-setup-upgrade()
{
    moma-dk-php-exec "bin/magento setup:upgrade"
}

# Method that will run the setup upgrade
moma-di-recompile()
{
    moma-dk-php-exec "bin/magento setup:di:compile"
}

# method that will recompile the static content
moma-recompile-static-content()
{
    moma-dk-php-exec "bin/magento setup:static-content:deploy"
}

# This is the method that will be enabling a m2 module
moma-module-enable()
{
    if [ -n "$1" ]; then
        moma-dk-php-exec "bin/magento module:enable $1" && moma-setup-upgrade
    else
        echo "You must say what is the module that you want to enable\n"
    fi
}

# This is the method that will be disabling a m2 module
moma-module-disable()
{
    if [ -n "$1" ]; then
        moma-dk-php-exec "bin/magento module:disable $1" && moma-setup-upgrade
    else
        echo "You must say what is the module that you want to enable\n"
    fi
}


# Method that will be fixing issues that m2 exists sometimes
moma-fix-issues()
{
    # cleaninig the cache and generated files
    moma-dk-php-exec "rm -Rf var/cache/* && rm -Rf generated/* ";

    # Running the cache flush
    moma-dk-php-exec "bin/magento cache:flush";

    # [optional]: you may uncomment if you need to have cache clean as well
    # moma-dk-php-exec "bin/magento cache:clean"

}

# Method that will set the environment to production mode
moma-set-mode-production()
{
    moma-dk-php-exec "bin/magento deploy:mode:set production"
}

# Method that will set the environment to developer mode
moma-set-mode-developer()
{
    moma-dk-php-exec "bin/magento deploy:mode:set developer"

}

# Method that will create your admin user on localhost
moma-localhost-create-admin()
{
    moma-dk-php-exec "bin/magento admin:user:create --admin-user='admin' --admin-password='admin1234' --admin-email='rafael.mendes@monsoonconsulting.com' --admin-firstname='Admin' --admin-lastname='Localhost'"
}

# Method that will run setup:static-content:deploy -f for m2
moma-static-content-deploy()
{
    moma-dk-php-exec "bin/magento setup:static-content:deploy -f"
}

# Method that will run the cache:clean function from m2
moma-cache-clean()
{
    moma-dk-php-exec "bin/magento cache:clean"
}

# Method that will run the cache:flush function from m2
moma-cache-flush()
{
    moma-dk-php-exec "bin/magento cache:flush"
}

# Method that will run the cache:flush for the full_page cache
moma-cache-fp()
{
    moma-dk-php-exec "bin/magento cache:flush full_page"
}

# Method that will enable the template hints
moma-template-hints-on()
{
    moma-dk-php-exec "bin/magento dev:template-hints:enable"
}

# Method that will enable the template hints
moma-template-hints-off()
{
    moma-dk-php-exec "bin/magento dev:template-hints:disable"
}

# First attempt to fix localhost
moma-fix-localhost()
{
    moma-cache-clean && moma-cache-flush && moma-set-mode-production && moma-set-mode-developer
}

# Method that will fix when you get a message saying that a module is outdated
moma-fix-module-version-is-outdated()
{
    moma-setup-upgrade && moma-cache-clean && moma-reindex && moma-recompile-static-content
}

moma-missing-class-on-di()
{
    # Clean of all elements on var
    cd ../ && sudo rm -rf var/di/* var/generation/* var/cache/* var/page_cache/* var/view_preprocessed/* var/composer_home/cache/*;

    ## back to docker folder
    cd .docker;

    ## running the magento 2 functions to regenerate those elements
    moma-di-recompile && moma-setup-upgrade && moma-static-content-deploy
}

## How to fix  Setup version for module '[module]' is not specified
moma-fix-module-version-is-not-specified()
{

    if [ -n "$1" ]; then
        moma-dk-php-exec "bin/magento module:enable --clear-static-content $1" && moma-setup-upgrade
    else
        echo "You must say what is the module that you want to enable\n"
    fi
}

moma-unlock-admin-user()
{
    if [ -n "$1" ]; then
        moma-dk-php-exec "bin/magento admin:user:unlock $1" && moma-cache-flush
    else
        echo "You must say what is the user that you want to unlock\n"
    fi
}

moma-cms-page-update()
{

    # Clean of view processed
    cd ../ && sudo rm -rf var/view_preprocessed/*;

    ## back to docker folder
    cd .docker;

    ## cleaning the caches
    moma-cache-clean
}