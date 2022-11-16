# Python scripts to create galaxy zoo Caesar configurations

Avoid manually plugging data into the Caesar UI, instead let the python client do it for you :)

## Use docker to run this code

This image depends on the upstream Panoptes Python Client project <https://github.com/zooniverse/panoptes-python-client>

``` sh
# build the image for use
docker-compose build
# run a bash console in the dev container
docker compose run --service-ports --rm caesar-scripts bash
# do your dev work and test it!

# setup the caesar system for GZ project to extract, reduce and push data to kade
python setup_ceaser_workflow.py --workflow $id

# Profit!
```
