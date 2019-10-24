# magerun 2

magerun2-enable()
{
    wget https://files.magerun.net/n98-magerun2.phar
    chmod +x ./n98-magerun2.phar
}

magerun2-disable()
{
    rm n98-magerun2.phar
}