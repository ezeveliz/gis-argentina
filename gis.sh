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

    printf "\nA continuación verifique las URLs desde: http://localhost:4040 \n\n"
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

rebuild() {
  BUILD_GRAPHS=True ORS_UID=${UID} ORS_GID=${GID} "${DOCKER_COMPOSE[@]}" up ors-app
}

# Initialise the Docker environment and the application
init () {

    env && update
}

update() {

  printf "\n Esto puede tardar mucho tiempo, varias horas \n\n"

  down -v \
    && update-assets \
    && rebuild \
    && down -v \
    && start
}

#######################################
# MENU
#######################################

case "$1" in

    destroy)
        destroy
        ;;
    down)
        down "${@:2}"
        ;;
    init)
        init
        ;;
    logs)
        logs "${@:2}"
        ;;
    restart)
        restart
        ;;
    start)
        start
        ;;
    stop)
        stop
        ;;
    update)
        update
        ;;
    state)
        state
        ;;
    *)
        cat << EOF
Servidor para gis-argentina
Uso:
    gis <comando> [opciones] [argumentos]
Comandos disponibles:
    init ...................................... Inicializar el ambiente de Docker y la aplicación(tarda un par de horas)
    start ..................................... Iniciar los contenedores(tarda unos minutos, 5 o 6)
    stop ...................................... Detener los contenedores
    restart ................................... Reiniciar los contenedores
    update .................................... Actualizar el ambiente de Docker(tarda un par de horas)
    state ..................................... Muestra el estado actual, ejecutando o no
    down [-v] ................................. Detener y destruir los contenedores
                                                    Opciones:
                                                        -v .................... También destruir los volúmenes
    destroy ................................... Remover todo el ambiente de docker
    logs [container] .......................... Mostrar y seguir los logs de todos los contenedores o del especificado
EOF
        exit
        ;;
esac

