#!/bin/bash
docker stop $(docker ps -q -f name=cracker | cut -d ' ' -f1)
docker rm cracker
