#!/bin/bash

function replace_var() {
  file=$1
  variable_name=$2
  variable_value=$3

  sed -i "s/$variable_name=.*/$variable_name=$variable_value/g" $file
}

function file_system_change_owner {
  app_base_dir=$1
  owner=$2

  echo "INFO: changing the owner:group to ${owner}:${owner} for ${app_base_dir}."
  sudo chown -R $owner:$owner ${app_base_dir}
}

function os_add_hostnames {
  project_name=$1
  hostname="$ENV_TYPE-$project_name.$ENV_DOMAIN_NAME"

  if [ "$project_name" == "docker" ]; then
    return
  fi

  if [ $(cat /etc/hosts | grep -c "$hostname") -eq 0 ]; then
    echo "INFO: adding host names entries in /etc/hosts file '127.0.0.1  ${hostname}'."
    echo "127.0.0.1  ${hostname}" | sudo tee -a /etc/hosts
  fi
}