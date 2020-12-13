#!/bin/bash
#Check if container is running and stop before rebuilding
CID=$(docker ps -q -f name=cracker | cut -d ' ' -f1)
if [ -z "$CID" ]
then
    docker build -t crackerjack .
else
    docker stop $CID
    docker rm cracker
    docker build -t crackerjack .
fi
 
