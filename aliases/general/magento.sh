#!/bin/bash

# Function that will import a magento 1 database
magento-db-import()
{

    if [ -z "$1" ]
    then
        echo "You must specify the path of the file to import";
    else
        # You will need to see if the file exists
        echo 'foi?'
    fi

}

## magento helpers
alias magerun-setup-incremental="docker-compose exec php sh -c 'n98-magerun sys:setup:incremental'"
alias magerun-setup-run="docker-compose exec php sh -c 'n98-magerun sys:setup:run'"
alias magerun-template-hints="docker-compose exec php sh -c 'n98-magerun dev:template-hints'"

## Check this: https://unix.stackexchange.com/questions/3773/how-to-pass-parameters-to-an-alias
## alias wrap_args='f(){ echo before "$@" after;  unset -f f; }; f'
## alias magerun-apply-price-rules='magerun sys:cron:run catalogrule_apply_all'

## magerun cron commands
alias magerun-cron-list="docker-compose exec php sh -c 'n98-magerun sys:cron:list'"
alias magerun-cron-run="docker-compose exec php sh -c 'n98-magerun sys:cron:run'"

# sending email commands
alias magento-send-email="docker-compose exec php sh -c 'n98-magerun sys:cron:run core_email_queue_send_all'"
alias magento-send-email-10="watch -n 10 docker-compose exec php sh -c 'n98-magerun sys:cron:run core_email_queue_send_all'"

## m1 how to clean the caches
alias magerun-cache-clean="docker-compose exec php sh -c 'n98-magerun cache:clean'"
alias magerun-cache-flush="docker-compose exec php sh -c 'n98-magerun cache:flush'"
alias magerun-cache-all="docker-compose exec php sh -c 'n98-magerun cache:flush && n98-magerun cache:clean'"

alias magerun-image-flush="docker-compose exec php sh -c 'n98-magerun media:cache:image:clear'"
alias magerun-jscss-flush="docker-compose exec php sh -c 'n98-magerun media:cache:jscss:clear'"
alias magerun-frontend-flush="docker-compose exec php sh -c 'n98-magerun media:cache:image:clear && n98-magerun media:cache:jscss:clear'"

alias magerun-reindex-all="docker-compose exec php sh -c 'n98-magerun index:reindex:all'"
alias magerun-create-user="docker-compose exec php sh -c 'n98-magerun admin:user:create rafael rafael.mendes@monsoonconsulting.com rafa1234 rafael mendes'"


# docker-compose exec php export PHP_IDE_CONFIG="serverName=xdebug" && php -dxdebug.profiler_enable=1 -dxdebug.remote_autostart=1 shell/removeCustomers.php
# php -dxdebug.profiler_enable=1 -dxdebug.remote_autostart=1 shell/removeCustomers.php

# admin:user:create rafa rafael.mendes+newtest@monsoonconsulting.com rafa1234567890 rafa rafa