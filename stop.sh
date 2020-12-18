#!/bin/bash

CID=$(docker ps -q -a -f name=cracker | cut -d ' ' -f1)
if [ ! -z "$CID" ]
then
    echo -n "Stopping container: "
    docker stop $CID
    read -r -p "Should I Remove the container [y/N]?" response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
    then
        echo -n "Removing container: "
        docker rm $CID
    fi
else
    echo "¯\_(ツ)_/¯ Unable to find the cracker container "
fi
