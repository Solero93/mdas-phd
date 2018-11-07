#!/usr/bin/env bash
set -e
docker build -t solero93/votingapp-builder .

docker rm -f myvotingapp-builder || true
docker run --name myvotingapp-builder -it -v $(pwd):/app solero93/votingapp-builder /bin/bash -c "./pipeline.sh"

docker build -t solero93/votingapp ./src/votingapp

docker rm -f myvotingapp || true
docker run --name myvotingapp -d -p 8085:8080 solero93/votingapp

docker push solero93/votingapp