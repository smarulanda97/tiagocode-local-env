#!/bin/bash

function nginx_add_host_file {
  docker_directory=$1
  name=$2
  installer_directory="$ENV_DIR/.installer"

  if [ "$name" == "docker" ]; then
    return
  fi

  hostname="$ENV_TYPE-$name.$ENV_DOMAIN_NAME$ENV_DOMAIN_EXT"
  destination_file="$docker_directory/nginx/sites/$name/$hostname.conf"

  echo "INFO: creating nginx config file $hostname."

  mkdir -p "$docker_directory/nginx/sites/$name";
  sudo rm -rf "$docker_directory/nginx/sites/$name/*";
  cp $installer_directory/config/nginx/example.conf $destination_file

  sed -i "s/server_name .*;$/server_name $hostname;/g" $destination_file
  sed -i "s/root .*;$/root \/var\/www\/$name\/public;/g" $destination_file
}