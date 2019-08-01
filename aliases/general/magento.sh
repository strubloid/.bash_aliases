## magento aliases ##

## magento helpers
alias magerun-setup-incremental='magerun sys:setup:incremental'
alias magerun-setup-run='magerun sys:setup:run'
alias magerun-template-hints='magerun dev:template-hints'
alias magerun-create-user='magerun admin:user:create rafael.mendes rafael.mendes@monsoonconsulting.com r@f@1234 rafael mendes'
alias magerun-apply-price-rules='magerun sys:cron:run catalogrule_apply_all'

## magerun cron commands
alias magerun-cron-list="magerun sys:cron:list"
alias magerun-cron-run="magerun sys:cron:run"

## alias to send email each 10 seconds
alias magento-send-email='watch -n 10 magerun sys:cron:run core_email_queue_send_all'


## m1 how to clean the caches
alias magerun-cache-clean="docker-compose exec php sh -c 'n98-magerun cache:clean'"
alias magerun-cache-flush="docker-compose exec php sh -c 'n98-magerun cache:flush'"
alias magerun-cache-all="docker-compose exec php sh -c 'n98-magerun cache:flush && n98-magerun cache:clean'"





# docker-compose exec php export PHP_IDE_CONFIG="serverName=xdebug" && php -dxdebug.profiler_enable=1 -dxdebug.remote_autostart=1 shell/removeCustomers.php
# php -dxdebug.profiler_enable=1 -dxdebug.remote_autostart=1 shell/removeCustomers.php

