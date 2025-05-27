#!/bin/bash

# Strubloid::general::mongodb


# This will check anything is doing something on
# the mongodb basic port 27017
check-mongodb-is-online()
{
  ss -tlnp | grep 27017
}