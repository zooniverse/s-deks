# Sloan Knowledge Extraction and Discovery Service

The Zooniverse API for supporting knoweldge extraction and discovery for machine learning systems.

## Requirements

SKEDS uses Docker to manage its environment, the requirements listed below are also found in `docker-compose.yml`. The means by which a new SKEDS instance is created with Docker is located in the `Dockerfile`. If you plan on using Docker to manage SKEDS, skip ahead to Installation.

SKEDS is primarily developed against stable MRI, currently 3.1. If you're running MRI Ruby you'll need to have the Postgresql client libraries installed as well as have [Postgresql](http://postgresql.org) version 13 running.

Optionally, you can also run the following:

* [Redis](http://redis.io) version >= 6

## Installation

We only support running Panoptes via Docker and Docker Compose. If you'd like to run it outside a container, see the above Requirements sections to get started.

## Usage

1. `docker-compose build`

2. `docker-compose up` to start the containers

    * If the above step reports a missing database error, kill the docker-compose process or open a new terminal window in the current directory and then run `docker-compose run --rm skeds bundle exec rake db:setup` to setup the database.

    * Alternatively use the following command to start a bash terminal session in the container `docker compose run --service-ports --rm skeds bash`

    * Run the tests in the container `docker compose run --service-ports --rm skeds RAILS_ENV=test bin/rspec`
