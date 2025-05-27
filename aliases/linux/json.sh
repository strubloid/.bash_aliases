#!/bin/bash

# Strubloid::linux:json


## This function is responsbile to add/remove data from json object in bash
## JSON_SOURCE: this is the variable instance that you will be adding/removing things on
## JSON_DATA_TO_ADD: this is the new data to add/merge
## JSON_INDEX: this is the palce that you should add data like person.list if we have to add something in this place
##             otherwise blank will add to the main root of the json file
## JSON_ACTION: this is the action that should be done, in this case we can accept: += and -=
##
json_change_data(){

  JSON_SOURCE=$1
  JSON_DATA_TO_ADD=$2
  JSON_INDEX=$3
  JSON_ACTION=$4

  echo "${JSON_SOURCE}" | jq ".$JSON_INDEX $JSON_ACTION $JSON_DATA_TO_ADD"

}

## This function uses the json_change_data to add a new element into
## the json source
json_add_data()
{
  json_change_data "$1" "$2" "$3" "+="
}

## This function uses the json_change_data to remove a new element into
## the json source
json_remove_data()
{
  json_change_data "$1" "$2" "$3" "+="
}

