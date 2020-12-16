#!/bin/bash
WORDLISTDIR=/usr/share/wordlists
#You should volume mount the below folder so all settings are saved on container stop, start, updates etc...
# i.e.   docker volume create crackerjack
#
docker run -d --runtime=nvidia -e "NGINX_HOST=127.0.0.1" -e "NGINX_PORT=4433" -p 4433:443 --mount type=bind,source=$WORDLISTDIR,target=/wordlists --mount source=crackerjack,target=/root/crackerjack/data/instance --name cracker crackerjack:latest 
