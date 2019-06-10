# Magento 2 Aliases

# how to turn it on the magento 2 production environment?
alias dk-project-production="bin/magento deploy:mode:set production"

# how to turn it on the magento 2 developer environment?
alias dk-project-developer="bin/magento deploy:mode:set developer"

## how to generate the mapping for all xml files
# bin/magento dev:urn-catalog:generate .idea/misc.xml
# docker-compose exec php bin/magento dev:urn-catalog:generate .idea/misc.xml