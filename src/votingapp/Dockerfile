# Aquí van los unittest tmb

# BUILDER
FROM golang:alpine3.8 AS builder
RUN apk update && apk add git

# Bajo primero las dependencias, porque así este layer no se regenera
# Los COPY son los que podrían hacer que el hash cambie
# Evita que bajes las dependencias todo el rato
COPY deps.sh .
RUN bash -c './deps.sh'

# Hemos reordenado para evitar invalidación de la caché en ese layer
COPY . .
RUN go build -o /deploy/votingapp && cp -r ui /deploy

# RUNTIME
FROM alpine:3.8
# WORKDIR hace mkdir y se cambia a él con cd
WORKDIR /app
COPY --from=builder ./deploy .

# Añadimos sleep para simular que el servidor tarda en levantarse
ENTRYPOINT [ "./votingapp" ]