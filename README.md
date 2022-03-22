# Sloan Knowledge Extraction and Discovery Service
Knowledge And Discovery Engine (KaDE)

The Zooniverse API for supporting knoweldge extraction and discovery for machine learning systems.

## Requirements

DEK-S uses Docker to manage its environment, the requirements listed below are also found in `docker-compose.yml`. The means by which a new S-DEKS instance is created with Docker is located in the `Dockerfile`. If you plan on using Docker to manage S-DEKS, skip ahead to Installation.

DEK-S is primarily developed against stable MRI, currently 3.1. If you're running MRI Ruby you'll need to have the Postgresql client libraries installed as well as have [Postgresql](http://postgresql.org) version 13 running.

Optionally, you can also run the following:

* [Redis](http://redis.io) version >= 6

## Installation

We only support running Panoptes via Docker and Docker Compose. If you'd like to run it outside a container, see the above Requirements sections to get started.

## Usage

1. `docker-compose build`

2. `docker-compose up` to start the containers

    * If the above step reports a missing database error, kill the docker-compose process or open a new terminal window in the current directory and then run `docker-compose run --rm api bundle exec rake db:setup` to setup the database.

    * Alternatively use the following command to start a bash terminal session in the container `docker compose run --service-ports --rm api bash`

    * Run the tests in the container `docker compose run --service-ports --rm api RAILS_ENV=test bin/rspec`

## API

The KaDE service has a json API

Create a new Training Data Export resource for use as a training data catalogue.

This resulting export resource will link to a csv training data catalogue at a hosted storage location

`POST /training_data_exports/`

Requires a JSON payload for creating a training data export for a known workflow, e.g.

``` JSON
{ training_data_export: { workflow_id: 3 } }
```

Get the details of a Training Data Export resource

`GET /training_data_exports/$id`

Returns a JSON payload describing the export resource

``` JSON
{
 'id': 1,
 'workflow_id': 3,
 'state' => 'started',
 'storage_path' => '/staging/training_catalogues/workflow-3.csv'
}
