#!/bin/bash
WORDLISTDIR=/usr/share/wordlists
#You should volume mount the below folder so all settings are saved on container stop, start, updates etc...
# i.e.   docker volume create crackerjack
#
#
#Check if container is already created before re-creating
CID=$(docker ps -q -a -f name=cracker | cut -d ' ' -f1)
if [ ! -z "$CID" ]
then
	echo -n "Starting existing container: "
	docker start cracker
	echo "Done!"
else
	echo "Existing Container Not Found..."
	echo -n "Creating: "
	docker run -d --runtime=nvidia -p 4433:443 --mount type=bind,source=$WORDLISTDIR,target=/wordlists --mount source=crackerjack,target=/root/crackerjack/data --name cracker crackerjack:latest 
	echo "Done!"
fi
