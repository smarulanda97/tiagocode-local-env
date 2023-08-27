#!/bin/bash

installer_directory=$(dirname "$0")

#######################################################################################
# Including the environment variables and functions
#######################################################################################

set -o allexport;
source "${installer_directory}/../.env";
set +o allexport;

source "${installer_directory}/functions/general.sh";
source "${installer_directory}/functions/repository.sh";
source "${installer_directory}/functions/nginx.sh";
source "${installer_directory}/functions/docker.sh";
source "${installer_directory}/functions/database.sh";

#######################################################################################
# Extra variables
#######################################################################################

docker_directory="${ENV_DIR}/${ENV_DOCKER_DIR_NAME}"
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
# 1. Clonning the git repositories required by this project
# 2. Replace the env variables of each project.
# 3. Create the Nginx config file of each project.
# 4. adding hostname entries in /etc/hosts (It might be needed)
#######################################################################################

for repo_id in "${repositories[@]}"
do
  repo_name=$(echo $repo_id | awk -F'[-]' '{print $2}')
  repo_directory="${ENV_DIR}/code/${repo_name}"
  if [ ${repo_name} == "docker" ]; then
      repo_directory="$docker_directory"
  fi

  clone_repository ${repo_directory} ${repo_id}

  env_replace_vars ${repo_directory} ${repo_name}

  nginx_add_host_file ${docker_directory} ${repo_name}

  os_add_hostnames ${repo_name}
done

os_add_hostnames "traefik"

#########################################################################################
## STARTING APPLICATION WITH DOCKER COMPOSE, AND CLEANING THE PREVIOUS DATA
## OF DB INSTALLATION (IT MIGHT BE NEEDED)
#########################################################################################

docker_compose_down $docker_directory
purge_database
docker_compose_up $docker_directory

########################################################################################
## RUNNING REQUIRED COMMANDS FOR THE APPLICATION
########################################################################################

file_system_change_owner $ENV_DIR $USER

for repo_id in "${repositories[@]}"; do
  repo_name=$(echo $repo_id | awk -F'[-]' '{print $2}')
  if ! [ "$repo_name" == "docker" ]; then
    for command in "${installation_commands[@]}"; do
      docker_compose_exec $docker_directory "/var/www/$repo_name" workspace "$command"
    done
  fi
done

docker_compose_ps $docker_directory

