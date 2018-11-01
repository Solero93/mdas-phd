docker build -t votingapp-builder .
docker run -it -v $(pwd):/app -w /app votingapp-builder bash -c "./pipeline.sh"

docker build -t solero93/votingapp votingapp ./src/votingapp

docker rm -f myvotingapp || true
docker run --name myvotingapp -d -p 8085:8080 votingapp

docker push solero93/votingapp