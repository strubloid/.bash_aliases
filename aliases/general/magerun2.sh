# magerun 2
m2-enable()
{
    wget https://files.magerun.net/n98-magerun2.phar
    sudo chmod +x ./n98-magerun2.phar
}

m2-disable()
{
    rm n98-magerun2.phar
}