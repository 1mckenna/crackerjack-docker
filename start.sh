#!/bin/bash
WORDLISTDIR=/usr/share/wordlists
docker run -d --runtime=nvidia -p 443:443 --mount type=bind,source=$WORDLISTDIR,target=/wordlists --privileged --name cracker crackerjack:latest 
