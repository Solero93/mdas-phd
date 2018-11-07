FROM alpine:3.8
RUN apk update && apk add python3 bash curl jq

COPY test.sh .
COPY votingapp.py .
COPY requirements.txt .

ENTRYPOINT [ "bash", "-c", "./test.sh"]
