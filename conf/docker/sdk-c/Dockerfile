FROM debian:buster-slim

# Install common tools
RUN \
    apt-get update -y && \
    apt-get install -y  --no-install-recommends \
        apt-transport-https \
        software-properties-common \
        ca-certificates \
        pkg-config \
        gpg \
        curl

# Install complier tools
RUN \
    apt-get update -y && \
    apt-get install -y  --no-install-recommends \
        build-essential \
        gcc \
        g++ \
        make \
        cmake

# Install Kafka C SDK
## Depend library
RUN \
    apt-get update -y && \
    apt-get install -y  --no-install-recommends \
        libglib2.0-dev

## Install Kafka C SDK from Confluent Platform
ADD install-librdkafka-dev.sh .
RUN bash install-librdkafka-dev.sh

# Container setting
WORKDIR /app
