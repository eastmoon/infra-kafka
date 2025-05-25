FROM python:slim-bullseye

RUN \
    apt-get update -y && \
    apt-get install -y \
        curl \
        git

RUN \
    pip install confluent-kafka

# Container setting
WORKDIR /app
