#!/usr/bin/env bash
set -e
# TODO Define builder_image_name, image_name and username variables to make it prettier
image='votingapp'
# registry=${REGISTRY:-'solero93'}
# export REGISTRY='blablabla'
network='votingapp-network'

# Creamos una red privada de contenedores
docker network create $network || true

# BUILD
# Crear el docker
docker build -t solero93/votingapp ./src/votingapp/

# INTEGRATION TESTS
# Borrar si ya existe
docker rm -f myvotingapp || true
# Ejecutar detached
docker run --name myvotingapp -d -p 8085:8080 --network $network solero93/votingapp

docker build -t votingapp-test ./test/votingapp
# Como el test se ejecuta y acaba, pues no hace falta el detached
# Pero lo borramos cuando haya acabado
docker run --rm --network $network -e VOTING_URL='http://myvotingapp:8080/vote' votingapp-test

# DELIVERY
docker push solero93/votingapp