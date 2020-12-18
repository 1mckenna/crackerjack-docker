#!/bin/bash
WORDLISTDIR=/usr/share/wordlists
#You should volume mount the below folder so all settings are saved on container stop, start, updates etc...
# i.e.   docker volume create crackerjack
#

#Docker Run Command
dockerCMD="docker run -d --runtime=nvidia -p 4433:443 --mount type=bind,source=$WORDLISTDIR,target=/wordlists --mount source=crackerjack,target=/root/crackerjack/data --name cracker crackerjack:latest"

#Check if container is already created before re-creating
CID=$(docker ps -q -a -f name=cracker | cut -d ' ' -f1)
if [ ! -z "$CID" ]
then
	echo "Existing container detected..."
        read -r -p "Should I Remove the existing container and Recreate [y/N]?" response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
        then
	    docker stop $CID >/dev/null
	    echo -n "Removing container: "
	    docker rm $CID
	    echo -n "Creating: "
	    exec $dockerCMD
        else
	    echo -n "Starting existing container: "
	    docker start cracker
        fi
	echo "Done!"
else
	echo "Existing Container Not Found..."
	echo -n "Creating: "
	exec $dockerCMD
	echo "Done!"
fi
