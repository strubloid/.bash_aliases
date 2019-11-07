#!/bin/bash

# Method that will run a docker command
moma-dk-exec()
{
    if [ -z "$2" ]
    then
        docker-compose exec php sh -c "$1"
    else
        docker-compose exec php sh -c "$1 $2"
    fi
}

# Method that will check what is the magento version
moma-magento-version()
{
    moma-dk-exec "bin/magento --version"
}

# Method that will check what is the status of the modules in the project
moma-module-check()
{
    moma-dk-exec "bin/magento module:status"
}

# Method that will reindex all indexes
moma-reindex()
{
    moma-dk-exec "bin/magento indexer:reindex"
}

# Method that will run the setup upgrade 
moma-setup-upgrade()
{
    moma-dk-exec "bin/magento setup:upgrade"
}

# Method that will run the setup upgrade
moma-di-recompile()
{
    moma-dk-exec "bin/magento setup:di:compile"
}

# method that will recompile the static content
moma-recompile-static-content()
{
    moma-dk-exec "bin/magento setup:static-content:deploy"
}

# This is the method that will be enabling a m2 module
moma-module-enable()
{
    if [ -n "$1" ]; then
        moma-dk-exec "bin/magento module:enable $1" && moma-setup-upgrade
    else
        echo "You must say what is the module that you want to enable\n"
    fi
}

# This is the method that will be disabling a m2 module
moma-module-disable()
{
    if [ -n "$1" ]; then
        moma-dk-exec "bin/magento module:disable $1" && moma-setup-upgrade
    else
        echo "You must say what is the module that you want to enable\n"
    fi
}


# Method that will be fixing issues that m2 exists sometimes
moma-fix-issues()
{
    # cleaninig the cache and generated files
    moma-dk-exec "rm -Rf var/cache/* && rm -Rf generated/* ";

    # Running the cache flush
    moma-dk-exec "bin/magento cache:flush";

    # [optional]: you may uncomment if you need to have cache clean as well
    # moma-dk-exec "bin/magento cache:clean"

}

# Method that will set the environment to production mode
moma-set-mode-production()
{
    moma-dk-exec "bin/magento deploy:mode:set production"
}

# Method that will set the environment to developer mode
moma-set-mode-developer()
{
    moma-dk-exec "bin/magento deploy:mode:set developer"

}

# Method that will create your admin user on localhost
moma-localhost-create-admin()
{
    moma-dk-exec "bin/magento admin:user:create --admin-user='admin' --admin-password='admin1234' --admin-email='rafael.mendes@monsoonconsulting.com' --admin-firstname='Admin' --admin-lastname='Localhost'"
}

# Method that will run the cache:clean function from m2
moma-cache-clean()
{
    moma-dk-exec "bin/magento cache:clean"
}

# Method that will run the cache:flush function from m2
moma-cache-flush()
{
    moma-dk-exec "bin/magento cache:flush"
}

# Method that will enable the template hints
moma-template-hints-on()
{
    moma-dk-exec "bin/magento dev:template-hints:enable"
}

# Method that will enable the template hints
moma-template-hints-off()
{
    moma-dk-exec "bin/magento dev:template-hints:disable"
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