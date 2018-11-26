#!/usr/bin/env bash
set -e

IMAGE=${REGISTRY:-solero93}/votingapp:${TAG:-latest}
APP=votingapp

# Parar todos los containers de este docker compose
docker-compose down
# Levanto tanto test como votingapp, pero test me la suda
docker-compose up -d --build
# Si esto revienta, el pipeline parará y no sigue
docker-compose run --rm "$APP-test"
# Push con el nombre en docker-compose.yml
docker-compose push $APP

set +e

# Ejecutar contenedor - redis se baja de DockerHub
kubectl run database --image redis
# Crea un servicio y expone el puerto - por defecto la exposición es interna
kubectl expose deployment database --port 6379
# Ejecutar votingapp e inyectar REDIS. database es resuelto por el DNS igual que en Docker
kubectl run $APP --image $IMAGE --env="REDIS=database:6379"
# exponer votingapp hacia fuera (LoadBalancer cuesta dinero)
kubectl expose deployment $APP --port 80 --type LoadBalancer

set -e

kubectl set image deployment/$APP votingapp=$IMAGE
kubectl scale --replicas=3 deployment/$APP

# REGISTRY=solero93 TAG=1.2 ./docker-pipeline.sh