#!/bin/bash

# Existe tanto "docker compose" como "docker-compose", de esta manera detecto y utilizo el correspondiente
if [ -x "$(command -v docker-compose)" ]; then
    DOCKER_COMPOSE=(docker-compose)
else
    DOCKER_COMPOSE=(docker compose)
fi

# Remove the entire Docker environment
destroy () {
    read -p "This will delete containers, volumes and images. Are you sure? [y/N]: " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then exit; fi
    "${DOCKER_COMPOSE[@]}" down -v --rmi all --remove-orphans
}

# Stop and destroy all containers
down () {
    "${DOCKER_COMPOSE[@]}" down "${@:1}"
}

# Create .env from .env.example
env () {
    if [ ! -f .env ]; then
        cp .env.example .env
    fi
}

# Display and tail the logs of all containers or the specified one's
logs () {
    "${DOCKER_COMPOSE[@]}" logs -f "${@:1}"
}

# Restart the containers
restart () {

    # docker-compose restart solo reinicia los contenedores en ejecución utilizando la misma imagen,
    # pero si hubo cambios en las mismas no los actualiza
    stop && start
}

# Start the containers
start () {
    ORS_UID=${UID} ORS_GID=${GID} "${DOCKER_COMPOSE[@]}" up -d

    if [[ "$1" != "--dont-print" ]]; then
        printf "\nA continuación verifique las URLs desde: http://localhost:4040 \n\n"
    fi
}

# Stop the containers
stop () {
    "${DOCKER_COMPOSE[@]}" stop
}

update-assets() {
  curl --request GET -sL \
       --url 'https://download.geofabrik.de/south-america/argentina-latest.osm.pbf'\
       --output './argentina-latest.osm.pbf'
}

# Initialise the Docker environment and the application
init () {

    # El script init SOLO se ejecuta durante la ejecución de esta función

    env \
        && update-assets \
        && down -v \

    start --dont-print

    printf "\nA continuación verifique las URLs desde: http://localhost:4040 \n\n"
}
