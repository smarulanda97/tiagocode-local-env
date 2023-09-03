#!/bin/bash

function nginx_add_host_file {
  docker_dir=$1
  project_name=$2
  installer_dir="$ENV_BASE_DIR/.installer"

  if [ "$project_name" == "docker" ]; then
    return
  fi

  echo "INFO: creating nginx config file $hostname."

  hostname="$ENV_TYPE-$project_name.$ENV_DOMAIN_NAME"
  destination_file="$docker_dir/nginx/sites/$hostname.conf"

  sudo rm -f "$docker_dir/nginx/sites/$hostname.conf";
  cp $installer_dir/config/nginx/example.conf $destination_file

  sed -i "s/server_name .*;$/server_name $hostname;/g" $destination_file
  sed -i "s/root .*;$/root \/var\/www\/$project_name\/public;/g" $destination_file
}