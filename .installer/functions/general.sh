#!/bin/bash

function replace_var() {
  FILE=$1
  VAR_NAME=$2
  VAR_VALUE=$3

  sed -i "s/$VAR_NAME=.*/$VAR_NAME=$VAR_VALUE/g" $FILE
}

function file_system_change_owner {
  app_base_dir=$1
  owner=$2

  echo "INFO: changing the owner:group to ${owner}:${owner} for ${app_base_dir}."
  sudo chown -R $owner:$owner ${app_base_dir}
}

function os_add_hostnames {
  name=$1
  hostname="$ENV_TYPE-$name.$ENV_DOMAIN_NAME$ENV_DOMAIN_EXT"

  if [ "$name" == "docker" ]; then
    return
  fi

  if [ $(cat /etc/hosts | grep -c "$hostname") -eq 0 ]; then
    echo "INFO: adding host names entries in /etc/hosts file '127.0.0.1  ${hostname}'."
    echo "127.0.0.1  ${hostname}" | sudo tee -a /etc/hosts
  fi
}