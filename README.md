# gis-argentina - WIP
* levantar: ORS_UID=${UID} ORS_GID=${GID} docker-compose up -d

* matar: docker-compose down

* para actualizar assets, cambiar el pbf al que apunta el docker-compose, luego setear la vble de entorno BUILD_GRAPHS=True y volver a levantar, ....tarda, ....mucho(2hs para toda argentina)

+ esta lista?: http://localhost:8080/ors/v2/health

* url de test: http://localhost:8080/ors/v2/directions/driving-car?start=-58.476580,-34.815821&end=-58.497284,-34.823133

* ultimos assets disponibles: https://download.geofabrik.de/south-america/argentina.html

* docs: https://giscience.github.io/openrouteservice/installation/Running-with-Docker.html