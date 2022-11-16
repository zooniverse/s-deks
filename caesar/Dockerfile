FROM python:3.9-slim

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /usr/src/app

RUN apt-get update && apt-get -y upgrade && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libmagic-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# install panoptes-client dependency
RUN pip install panoptes-client

# install the script code
COPY . .
