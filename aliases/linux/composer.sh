#!/bin/bash

# Strubloid::linux::composer

# This will be cleaning the composer cache
composer-clear-cache()
{
  echo "[Composer]: Cache Clean"
  composer clearcache
  read -p "Should we delete the $HOME/.composer? [y/n] : " removeMainComposerFolder

  if [[ "$removeMainComposerFolder" =~ [yY](es)?$ ]]; then
    sudo rm -rf ~/.composer
  fi
}

# This will be cleaning the composer cache
composer-cache-clean()
{
  composer-clear-cache
}



