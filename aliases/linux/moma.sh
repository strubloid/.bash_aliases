#!/bin/bash

# Strubloid::general::moma

# SOURCE=$(dirname "$(readlink -f "$0")")
# PROJECTSSOURCE='~/Projects/'


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

# Method that will run docker command in varnish container
moma-dk-varnish-exec()
{
    docker-compose exec varnish sh -c "$1"
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

# Method that will set the base url of the magento 2 project
moma-set-base-url()
{
    if [ -n "$1" ]; then
        moma-dk-php-exec "bin/magento setup:store:set --base-url='$1'" && moma-cache-flush
    else
        echo "You must specify the base url\n"
    fi
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

# Method that will run the setup install
moma-setup-upgrade()
{
    moma-dk-php-exec "bin/magento setup:install"
}

# Method that will run the setup install and wont delete the generated folder
moma-setup-upgrade-keep-generated()
{
    moma-dk-php-exec "bin/magento setup:install --keep-generated"
}

# Method that will run the setup upgrade
moma-setup-upgrade()
{
    moma-dk-php-exec "bin/magento setup:upgrade"
}

# Method that will enable the Dry run
moma-setup-dryrun-install()
{
    moma-dk-php-exec "bin/magento setup:install --dry-run=1"
}

# Method that will enable the Dry run
moma-setup-dryrun-upgrade()
{
    moma-dk-php-exec "bin/magento setup:upgrade --dry-run=1"
}

# Method that will convert the install scripts
moma-convert-install()
{
    # Check if this is the correct one or the next one in line
    # moma-dk-php-exec "bin/magento setup:install --convert-old-scripts=1"
    moma-dk-php-exec "bin/magento setup:install --convert_old_scripts=1"
}

# Method that will convert the upgrade scripts
moma-convert-upgrade()
{
    # Check if this is the correct one or the next one in line
    # moma-dk-php-exec "bin/magento setup:upgrade --convert-old-scripts=1"
    moma-dk-php-exec "bin/magento setup:upgrade --convert_old_scripts=1"
}

# Method that will set all modules to be whitelisted
moma-setup-whitelist-all()
{
    # Check if this is the correct one or the next one in line
    # moma-dk-php-exec "bin/magento declaration:generate:whitelist --module-name=all"
    moma-dk-php-exec "bin/magento setup:db-declaration:generate-whitelist --module-name=all"
}

# Method that will set all modules to be whitelisted
moma-setup-whitelist-specific-module()
{
    if [ -n "$1" ]; then
        # Check if this is the correct one or the next one in line
        # moma-dk-php-exec "bin/magento declaration:generate:whitelist --module-name=$1"
        moma-dk-php-exec "bin/magento setup:db-declaration:generate-whitelist --module-name=$1"
    else
        echo "You must specify the module in this case\n"
    fi
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
    moma-dk-php-exec "bin/magento admin:user:create --admin-user='rafael' --admin-password='rafa1234' --admin-email='rafael.mendes+localhost@monsoonconsulting.com' --admin-firstname='Admin' --admin-lastname='Localhost'"
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

# Method that will clean the varnish cache
moma-varnish-flush()
{
  if [ -n "$2" ]; then
      docker-compose exec varnish sh -c "varnishadm -T 127.0.0.1:$2 -S /etc/varnish/secret ban 'req.http.host == $1'"
  else
      echo  "varnishadm -T 127.0.0.1:6082 -S /etc/varnish/secret ban 'req.http.host == $1'"

      docker-compose exec varnish sh -c "varnishadm -T 127.0.0.1:6082 -S /etc/varnish/secret ban 'req.http.host == $1'"
  fi
}

## This will clean the varnish cache for centralbank
moma-varnish-centralbank-flush()
{
  ## docker-compose exec varnish sh -c
  ## varnishadm -T 127.0.0.1:6082 -S /etc/varnish/secret ban "req.http.host == collectorcoins.ie.test"
  docker-compose exec varnish sh -c "varnishadm -T 127.0.0.1:6082 -S /etc/varnish/secret ban 'req.http.host == collectorcoins.ie.test'"
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
    moma-static-content-deploy && moma-di-recompile && moma-cache-clean && moma-setup-upgrade
}

moma-regenerate()
{
    # Clean of all elements on var
    cd ../ && sudo rm -rf var/view_preprocessed/* pub/static/* var/generation/*;

    ## back to docker folder
    cd .docker;

    ## running the static content deploy and cache flush
    moma-static-content-deploy && moma-cache-flush
}

moma-js-refresh()
{
    if [ -n "$1" ]; then
        moma-dk-php-exec "find ./pub/ -iname $1 -delete";
        moma-dk-php-exec "bin/magento setup:static-content:deploy -f"
        moma-dk-php-exec "bin/magento setup:di:compile"
    else
        echo "You must say what what is the file to remove and refresh the content from it\n"
    fi


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

moma-clean-m2()
{
     # TODO  use this command to clean M2 varnish, you need to coneect to varnish container:
     docker-compose exec varnish sh -c 'varnishadm "ban req.url ~ /"';
     moma-dk-php-exec "bin/magento cache:flush full_page"
}


moma-layout-changes()
{
    # Clean of view processed
    ## cd ../ && sudo rm -rf var/view_preprocessed/*;

    # back to docker folder
    ## cd .docker;

    ## TODO: you must check how to get the current file changed, go to the view_processed and delete just that file

    ## cleaning the caches
    moma-cache-clean;

    ## deploy
    moma-static-content-deploy -f;
}

moma-update-javascript()
{

    # Clean of view processed
    cd ../ && sudo rm -Rf ../var/view_preprocessed/* ../pub/static/* ;

    # back to docker folder
    cd .docker;

    ## deploy
    moma-static-content-deploy;

    ## cleaning the caches
    moma-cache-clean;
}

m2-n98()
{
    echo "Should PHP higher than 7.2.0?: (Y)es (N)o"
    read -r phphigher

    if [[ "$phphigher" =~ ^(yes|y|Yes|YES)$ ]]
    then
        echo "Installation of the NEW version of n98-magerun2.phar"
        docker-compose exec php sh -c "curl -O https://files.magerun.net/n98-magerun2.phar";
    else
        echo "Installation of an OLD version of n98-magerun2.phar"
        docker-compose exec php sh -c "curl -o n98-magerun2.phar https://files.magerun.net/n98-magerun2-3.2.0.phar";
    fi

    docker-compose exec php sh -c "chmod 777 n98-magerun2.phar";
    docker-compose exec php sh -c "mv n98-magerun2.phar /usr/local/bin/";
}

## Refresh translation
m2-refresh-translation()
{
  # Removing the translation json
  docker-compose exec php sh -c "find pub/static/frontend -name js-translation.json -exec rm -rf {} \;" \
  && docker-compose exec php sh -c "bin/magento cache:clean translate full_page" \
  && docker-compose exec varnish varnishadm "ban req.url ~ /" \
  && moma-cache-flush
}
