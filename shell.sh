#!/bin/bash
docker exec -it $(docker ps -q -f name=cracker | cut -d ' ' -f1) bash
