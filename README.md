# Crackerjack-Docker
A docker container for Crackerjack (Web Interface for hashcat)

# Based off the work here
* Crackerjack (https://github.com/ctxis/crackerjack)
* Hashcat Docker(https://github.com/dizcza/docker-hashcat)

# Kali Rolling Setup
* Built and tested on Kali Rolling 2020.4 

## Setup Nvidia Docker Environment
1. Install Nvidia Drivers, Nvidia Cuda Toolkit and docker
`sudo apt-get install nvidia-driver nvidia-cuda-toolkit`
2. Install Nvidia Container Runtime (Follow the steps outlined in thier git if the below doesn't work)
  * `curl -s -L https://nvidia.github.io/nvidia-container-runtime/gpgkey | sudo apt-key add -distribution=$(. /etc/os-release;echo $ID$VERSION_ID)`

  * `curl -s -L https://nvidia.github.io/nvidia-container-runtime/ubuntu20.04/nvidia-container-runtime.list | sudo tee /etc/apt/sources.list.d/nvidia-container-runtime.list`
  * `sudo apt-get update`
  * `sudo apt-get install nvidia-container-runtime docker.io`
  * `sudo mkdir -p /etc/systemd/system/docker.service.d`
  *
    ```
    sudo tee /etc/systemd/system/docker.service.d/override.conf <<EOF 
    [Service] 
    ExecStart= 
    ExecStart=/usr/sbin/dockerd --host=fd:// --add-runtime=nvidia=/usr/bin/nvidia-container-runtime
    EOF
    ```
  * `ln -s /sbin/ldconfig /sbin/ldconfig.real`
  * `sudo systemctl daemon-reload`
  * `sudo systemctl restart docker`


# Container Setup Notes
## NGINX Servername and Port
You can modify the default host and port crackerjack is served on by passing in the below environment variables when you start the container.

| **Environment Variable** | **Comment** | **Default Value**
| :------------------------- | :--------------------: |:---------------:|
| NGINX_HOST                 | Used to set the nginx server_name value| 127.0.0.1         |
| NGINX_PORT                 | Used to set the port being exposed on the docker frontend | 4433               |
| CERTSUBJECT                | Used to set the certificate subject to something other than the default| /C=US/O=Crackerjack/CB=crackerjack.lan |


## SSL
* If you're wanting to use your own certificates bind mount them to the following locations otherwise they will be generated on the start of the container
  * /root/crackerjack/data/config/http/ssl.pem
  * /root/crackerjack/data/config/http/ssl.crt

## Persistent Data 
* If you are wanting to persist data you need to set your volume mount to /root/crackerjack/data as all persistant data is stored here.
  * `docker volume create crackerjack`
  * Then ensure to mount the volume to the container via the following docker option `--mount source=crackerjack,target=/root/crackerjack/data`

## Crackerjack Settings
* Hashcat executable: /root/hashcat/hashcat
* Rules Path: /root/hashcat/rules
* Wordlist Path: /wordlists [check or modify in start.sh]
* Uploaded Hashes Path: /root/crackerjack/data/uploads

## Helper Scripts
* build.sh - Build the Dockerfile (also stops and removes the container if its currently running)
* start.sh - Runs/Starts the container with the default settings
* stop.sh - Stops and removes the container
* shell.sh - Exec into the running container

# Related Repos
* https://github.com/ctxis/crackerjack
* https://github.com/dizcza/docker-hashcat
* https://github.com/NVIDIA/nvidia-container-runtime
