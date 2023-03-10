#!/bin/bash

# Strubloid::general::magento

## magento helpers
alias magerun-setup-incremental="docker-compose exec php sh -c 'n98-magerun sys:setup:incremental'"
alias magerun-setup-run="docker-compose exec php sh -c 'n98-magerun sys:setup:run'"
alias magerun-template-hints="docker-compose exec php sh -c 'n98-magerun dev:template-hints'"

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

## Magerun commands
magerun2-download()
{
  wget https://files.magerun.net/n98-magerun2.phar
  sudo chmod +x ./n98-magerun2.phar
}

# quick function to remove a magerun in the current local that you downloaded
magerun2-remove()
{
  rm n98-magerun2.phar
}

## database related
alias dk-database-login="docker-compose exec database bash"
alias dk-database-query='docker-compose exec database mysql -u root -proot -e "select * from magento.catalogsearch_result"'
alias dk-database-query-watch='watch -n 1 docker-compose exec database mysql -u root -proot -e "select * from magento.catalogsearch_result"'

## how to create a watch with queries
## watch -n 1 -x docker-compose exec database mysql -u root -proot -e "select count(*) from magento.pallasfoods_customer_pricebook"
alias dk-database-dump="docker-compose exec database sh -c 'mysqldump -h localhost -u root -proot magento --single-transaction' > dump.sql"
alias dk-database-processlist='docker-compose exec database mysqladmin -u root -proot -i 1 processlist'
alias dk-database-core-config-data='watch -n 1 -x docker-compose exec database mysql -u root -proot -e "select * from magento.core_config_data where path like \"%base_url%\"; "'
alias dk-database-import='watch -n 1 -x docker-compose exec database mysql -u root -proot -e "SELECT table_schema \"DB Name\", ROUND(SUM(data_length + index_length) / 1024 / 1024, 1) \"DB Size in MB\", SUM(data_length + index_length) \"DB Size in Bytes\" FROM information_schema.tables WHERE table_schema = \"magento\" GROUP BY table_schema;"'
alias dk-create-admin-user="docker-compose exec php sh -c \"php bin/magento admin:user:create --admin-user='rafael' --admin-password='rafa1234' --admin-email='strubloid@strubloid.com' --admin-firstname='strubloid' --admin-lastname='strubloid' \""

# Magento comments
# docker-compose exec php export PHP_IDE_CONFIG="serverName=xdebug" && php -dxdebug.profiler_enable=1 -dxdebug.remote_autostart=1 shell/removeCustomers.php
# php -dxdebug.profiler_enable=1 -dxdebug.remote_autostart=1 shell/removeCustomers.php
