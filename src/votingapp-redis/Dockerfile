# BUILDER
FROM golang:alpine3.8 AS builder
RUN apk update && apk add git python3 bash

COPY deps.sh . 
RUN bash -c './deps.sh'

COPY . .
RUN go build -o /deploy/votingapp && cp -r ui /deploy

# RUNTIME
FROM alpine:3.8
WORKDIR /app
COPY --from=builder /deploy .
ENTRYPOINT [ "./votingapp" ]