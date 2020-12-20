#!/bin/bash

#############################################################
# COMMON SETUP SECTION
#############################################################
WORDLISTDIR=/usr/share/wordlists
#You should volume mount the below folder so all settings are saved on container stop, start, updates etc...
# i.e.   docker volume create crackerjack


#############################################################
# STANDARD SETUP SECTION
#############################################################
#Docker Run Command for the standard setup
dockerCMD="docker run -d --runtime=nvidia -p 4433:443 --mount type=bind,source=$WORDLISTDIR,target=/wordlists --mount source=crackerjack,target=/root/crackerjack/data --name cracker crackerjack:latest"

#############################################################
# REVERSE PROXY SETUP SECTION
#############################################################
#Docker Run Command example for traefik 2 as a reverse proxy. 
#If you already have traefik setup with letsencrypt then you should be able to just modify the variables below and run the script
#Uncomment the lines below to use and comment the dockerCMD line above
#TRAEFIK_HOSTNAME="cracker.somecoolnamehere.duckdns.org" #CHANGE THIS TO BE YOUR EXTERNAL HOST NAME
#TRAEFIK_NETWORK="traefik_proxy"               #SET THIS VALUE TO THE VAULE OF YOUR TRAEFIK NETWORK
#NGINX_PORT=4433                                #THIS VALUE IS USED IN A TRAEFIK CONFIGURATION TO SET THE PORT gunicorn RUNS ON
#dockerCMD="docker run -d --runtime=nvidia --network ${TRAEFIK_NETWORK} --restart unless-stopped -e "TRAEFIK_ENABLED=true" -e "NGINX_PORT=${NGINX_PORT}" -p ${NGINX_PORT}:${NGINX_PORT} -l "traefik.enable=true" -l "traefik.http.routers.crackerjack.entrypoints=https" -l "traefik.http.routers.crackerjack.rule=Host\(\`${TRAEFIK_HOSTNAME}\`\)" -l "traefik.http.routers.crackerjack.service=crackerjack" -l "traefik.http.routers.crackerjack.middlewares=refheader" -l "traefik.frontend.headers.SSLProxyHeaders=X-Forwarded-Proto" -l "traefik.http.middlewares.refheader.headers.hostsproxyheaders=X-Forwarded-Host" -l "traefik.http.middlewares.refheader.headers.sslredirect=true" -l "traefik.http.middlewares.refheader.headers.sslhost=${TRAEFIK_HOSTNAME}" -l "traefik.http.middlewares.refheader.headers.sslforcehost=true" -l "traefik.http.middlewares.refheader.headers.sslproxyheaders.X-Forwarded-Proto=https" -l "traefik.http.routers.crackerjack.tls=true" -l "traefik.http.routers.crackerjack.tls.certresolver=le" -l "traefik.http.services.crackerjack.loadbalancer.server.port=${NGINX_PORT}" --mount type=bind,source=$WORDLISTDIR,target=/wordlists --mount source=crackerjack,target=/root/crackerjack/data --name cracker crackerjack:latest"


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
