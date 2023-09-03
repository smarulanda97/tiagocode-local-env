#!/bin/bash

installer_dir=$(dirname "$0")

#######################################################################################
# Including the environment variables and functions
#######################################################################################

set -o allexport;
source "${installer_dir}/../.env";
set +o allexport;

source "${installer_dir}/functions/general.sh";
source "${installer_dir}/functions/repository.sh";
source "${installer_dir}/functions/nginx.sh";
source "${installer_dir}/functions/docker.sh";
source "${installer_dir}/functions/database.sh";

#######################################################################################
# Extra variables
#######################################################################################

docker_dir="${ENV_BASE_DIR}/${ENV_DOCKER_DIR_NAME}"
IFS="," read -a repositories <<< $ENV_REPOSITORIES
installation_commands=(
  "composer install"
  "php artisan key:generate"
  "php artisan migrate"
  "php artisan db:seed"
  "php artisan cache:clear"
  "npm install"
  "npm run build"
  "chown -R laradock:laradock storage"
)

#######################################################################################
# 1. Cloning the git repositories required by this project
# 2. Replace the env variables of each project.
# 3. Create the Nginx config file of each project.
# 4. adding hostname entries in /etc/hosts (It might be needed)
#######################################################################################

for repo_id in "${repositories[@]}"
do
  repo_name=$(echo $repo_id | awk -F'[-]' '{print $2}')
  repo_dir="${ENV_BASE_DIR}/code/${repo_name}"
  if [ ${repo_name} == "docker" ]; then
      repo_dir="$docker_dir"
  fi

  clone_repository ${repo_dir} ${repo_id}

  env_replace_vars ${repo_dir} ${repo_name}
done

nginx_add_host_file ${docker_dir} "admin"

os_add_hostnames "website"
os_add_hostnames "admin"
os_add_hostnames "traefik"
os_add_hostnames "portainer"

#########################################################################################
## STARTING APPLICATION WITH DOCKER COMPOSE, AND CLEANING THE PREVIOUS DATA
## OF DB INSTALLATION (IT MIGHT BE NEEDED)
#########################################################################################

docker_compose_down $docker_dir
purge_database
docker_compose_up $docker_dir

########################################################################################
## RUNNING REQUIRED COMMANDS FOR THE APPLICATION
########################################################################################

file_system_change_owner $ENV_BASE_DIR $USER

for repo_id in "${repositories[@]}"; do
  repo_name=$(echo $repo_id | awk -F'[-]' '{print $2}')
  if ! [ "$repo_name" == "docker" ] && ! [ "$repo_name" == "website" ]; then
    for command in "${installation_commands[@]}"; do
      docker_compose_exec $docker_dir "/var/www/$repo_name" workspace "$command"
    done
  fi
done

docker_compose_ps $docker_dir

