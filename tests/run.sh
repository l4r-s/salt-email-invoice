#!/bin/bash

IMAGE_NAME=$1
docker run -it --env-file tests/envs.list.private $IMAGE_NAME