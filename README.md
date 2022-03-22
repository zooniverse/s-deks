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

### User Reductions Resource

### Create a new User Reductions resource

This resulting user reduction resource represents the known aggregated state of a subject.

This end point is meant to be used by Caesar system to post aggregated subject reductions into this system.

`POST /user_reductions/`

Requires a JSON payload for creating a User Reduction resource. The payload is static and derived from the Caesar system internals.

``` JSON
{
  'user_reduction': {
    'id': 4,
    'reducible': {
      'id': 3,
      'type': 'Workflow'
    },
    'data': {
      '0' => 3,
      '1' => 9,
      '2' => 0
    },
    'subject': {
      'id': 999,
      'metadata': { '#name' => '8000_231121_468' },
      'created_at': '2021-08-06T11:08:53.918Z',
      'updated_at': '2021-08-06T11:08:53.918Z'
    },
    'created_at': '2021-08-06T11:08:54.000Z',
    'updated_at': '2021-08-06T11:08:54.000Z'
  }
}
```

### Training Data Exports Resource

### Create a new Training Data Export resource

This resulting export resource will link to a csv training data catalogue at a hosted storage location

`POST /training_data_exports/`

Requires a JSON payload for creating a training data export for a known workflow, e.g.

``` JSON
{ 'training_data_export': { 'workflow_id': 3 } }
```

Example using Curl to create an export against localhost

``` sh
curl -u sdeks-user:sdeks-password -H 'Content-Type: application/json' -X POST http://localhost:3001/training_data_exports -d '{ "training_data_export": { "workflow_id": 3 } }'
```

### Get the details of a Training Data Export resource

`GET /training_data_exports/$id`

Returns a JSON payload describing the export resource

``` JSON
{
 'id': 1,
 'workflow_id': 3,
 'state' => 'started',
 'storage_path' => '/staging/training_catalogues/workflow-3.csv'
}
