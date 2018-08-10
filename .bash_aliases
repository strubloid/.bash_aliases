## adding the maiun configuration aliases
if [ -f ~/rafael/.configurations ]; then
    . ~/rafael/.configurations
fi

## adding the rafal mysql aliases
if [ -f ~/rafael/.mysql ]; then
    . ~/rafael/.mysql
fi

## adding the rafael aliases
if [ -f ~/rafael/.rafael ]; then
    . ~/rafael/.rafael
fi

## adding the magento aliases
if [ -f ~/rafael/.magento_aliases ]; then
    . ~/rafael/.magento_aliases
fi

## adding the sf9 aliases
if [ -f ~/rafael/.sf9 ]; then
    . ~/rafael/.sf9
fi

## adding linux shortcuts
if [ -f ~/rafael/.linux ]; then
    . ~/rafael/.linux
fi

## adding version control aliases (git and mercurial)
if [ -f ~/rafael/.version-control ]; then
    . ~/rafael/.version-control
fi
