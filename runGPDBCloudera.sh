#!/bin/bash
# Dockerfiles are located under `docker` directory
docker-compose -f docker/docker-compose.yml up -d


# use this command to rebuild docker images if there are some changes
#docker-compose -f docker/docker-compose.yml up --build