#!/bin/bash

OUR_ID="`sudo docker container ls | grep cryptoanarchy | cut -f 1 -d ' '`"

echo "Our ID: $OUR_ID"

sudo docker cp "$OUR_ID:$HOME/cadr-build" /packages
echo "Packages copied, building container"
sudo docker build -t cadr:dev - < Dockerfile
echo "Running container"
sudo docker run -d --name cadr --tmpfs /tmp --tmpfs /run --tmpfs /run/lock -v /sys/fs/cgroup:/sys/fs/cgroup:ro cadr:dev 
sleep 5
echo "Getting their ID"
THEIR_ID="`sudo docker container ls | grep cadr | cut -f 1 -d ' '`"
echo "Their ID: $THEIR_ID"
sudo docker cp /packages "$THEIR_ID:/srv/local-apt-repository"
echo "Executing bash"
sudo docker exec -it cadr bash
