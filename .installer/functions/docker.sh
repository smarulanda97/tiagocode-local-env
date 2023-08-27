#!/bin/bash

function docker_compose_up {
  docker_directory=$1

  echo "INFO: building and starting docker compose services '$ENV_DOCKER_CONTAINERS'."
  docker compose -f $docker_directory/docker-compose.yml build $ENV_DOCKER_CONTAINERS
  docker compose -f $docker_directory/docker-compose.yml up -d $ENV_DOCKER_CONTAINERS
}

function docker_compose_down {
  docker_directory=$1

  echo "INFO: removing docker compose services."
  docker compose -f $docker_directory/docker-compose.yml down
}

function docker_compose_ps {
  docker_directory=$1

  docker compose -f $docker_directory/docker-compose.yml ps
}

function docker_compose_exec {
  docker_directory=$1
  workdir=$2
  service=$3
  command=$4

  docker compose -f $docker_directory/docker-compose.yml exec --user=root --workdir=${workdir} ${service} ${command}
}