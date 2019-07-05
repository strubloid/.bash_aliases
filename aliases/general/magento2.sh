# Magento 2 Aliases

# how to turn it on the magento 2 production environment?
alias m2-project-production="bin/magento deploy:mode:set production"

# how to turn it on the magento 2 developer environment?
alias m2-project-developer="bin/magento deploy:mode:set developer"

alias m2-create-admin-user="bin/magento admin:user:create --admin-user='rafael' --admin-password='rafa1234' --admin-email='rafael@monsoonconsulting.com' --admin-firstname='Rafael' --admin-lastname='Mendes'"

alias m2-template-on="docker-compose exec php sh -c 'php bin/magento dev:template-hints:enable'"
alias m2-template-off="docker-compose exec php sh -c 'php bin/magento dev:template-hints:disable'"

alias m2-cache-clean="docker-compose exec php sh -c 'php bin/magento cache:clean'"
alias m2-cache-flush="docker-compose exec php sh -c 'php bin/magento cache:flush'"
alias m2-cleanall="docker-compose exec php sh -c 'php bin/magento cache:clean && php bin/magento cache:flush'"

## how to generate the mapping for all xml files
# bin/magento dev:urn-catalog:generate .idea/misc.xml
# docker-compose exec php bin/magento dev:urn-catalog:generate .idea/misc.xml