FROM alpine:3.8

WORKDIR /app

RUN apk update && apk add git go libc-dev curl jq python3 bash