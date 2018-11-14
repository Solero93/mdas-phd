#!/usr/bin/env bash
set -e

# Parar todos los containers de este docker compose
docker-compose down
# Levanto tanto test como votingapp, pero test me la suda
docker-compose up -d --build
# Si esto revienta, el pipeline parará y no sigue
docker-compose run --rm votingapp-test
# Push con el nombre en docker-compose.yml
docker-compose push votingapp


# REGISTRY=solero93 ./docker-pipeline.sh