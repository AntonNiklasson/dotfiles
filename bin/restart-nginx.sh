#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title restart containers
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🔄

#  --

cd ~/code/sana/sana-sierra-mono

docker-compose -p sierra stop postgres nginx
HOST_DOCKER_INTERNAL_NAME="host.docker.unused" HOST_DOCKER_INTERNAL_IP="127.0.0.1" docker-compose -p sierra up --force-recreate --detach postgres nginx

open raycast://confetti

echo "Containers restarted!"
