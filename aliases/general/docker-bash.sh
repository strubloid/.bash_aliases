#!/bin/bash

# Method that will run a docker command
mongento-dk-exec()
{
    if [ -z "$2" ]
    then
        docker-compose exec php sh -c "$1"
    else
        docker-compose exec php sh -c "$1 $2"
    fi
}

# Method that will check what is the status of the modules in the project
mongento-module-check()
{
    mongento-dk-exec "bin/magento module:status";
}

# This is the method that will be enabling a m2 module
mongento-module-enable()
{
    if [ -n "$1" ]; then
        mongento-dk-exec "bin/magento module:enable $1";
        mongento-dk-exec "bin/magento setup:upgrade";
    else
        echo "You must say what is the module that you want to enable\n"
    fi


    ## Check this later
#    The following modules have been enabled:
#    - Mastering_SampleModule
#
#    To make sure that the enabled modules are properly registered, run 'setup:upgrade'.
#    Cache cleared successfully.
#    Generated classes cleared successfully. Please run the 'setup:di:compile' command to generate classes.
#    Info: Some modules might require static view files to be cleared. To do this, run 'module:enable' with the --clear-static-content option to clear them.

}

# This is the method that will be disabling a m2 module
mongento-module-disable()
{
    if [ -n "$1" ]; then
        mongento-dk-exec "bin/magento module:disable $1";
        mongento-dk-exec "bin/magento setup:upgrade";
    else
        echo "You must say what is the module that you want to enable\n"
    fi
}


# Method that will be fixing issues that m2 exists sometimes
mongento-fix-issues()
{
    # cleaninig the cache and generated files
    mongento-dk-exec "rm -Rf var/cache/* && rm -Rf generated/* "

    # Running the cache flush
    mongento-dk-exec "bin/magento cache:flush"

    # [optional]: you may uncomment if you need to have cache clean as well
    # mongento-dk-exec "bin/magento cache:clean"

}