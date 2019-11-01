# Magento 2 Aliases

# how to turn it on the magento 2 developer environment?
alias m2-create-admin-user="bin/magento admin:user:create --admin-user='rafael' --admin-password='rafa1234' --admin-email='rafael@monsoonconsulting.com' --admin-firstname='Rafael' --admin-lastname='Mendes'"
alias m2-install-n98="docker-compose exec php sh -c 'curl -O https://files.magerun.net/n98-magerun2.phar && chmod 777 n98-magerun2.phar'"
alias m2-flushall="docker-compose exec php sh -c 'php bin/magento indexer:reindex && php bin/magento cache:clean && php bin/magento cache:flush && php bin/magento cache:enable'"
alias m2-recompile="docker-compose exec php sh -c 'php bin/magento setup:di:compile'"

## how to generate the mapping for all xml files
# bin/magento dev:urn-catalog:generate .idea/misc.xml
# docker-compose exec php bin/magento dev:urn-catalog:generate .idea/misc.xml
# https://collectorcoins.ie.test/static/version1566812199/frontend/Monsoon/bootstrap3/en_IE/Magento_Theme/core.css