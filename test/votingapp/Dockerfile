FROM python:alpine3.8
RUN apk update && apk add bash curl jq

COPY requirements.txt .
# Instalar dependencias solo una vez si cambia el código
RUN pip install -r requirements.txt --quiet
COPY test.sh .
COPY votingapp.py .

ENTRYPOINT [ "bash", "-c", "./test.sh"]
