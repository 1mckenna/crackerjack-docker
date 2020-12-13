# Crackerjack-Docker
A docker container for Crackerjack (Web Interface for hashcat)

# Based off the work done here (Thanks!)
* Crackerjack (https://github.com/ctxis/crackerjack)
* Hashcat Docker(https://github.com/dizcza/docker-hashcat)

# Kali Rolling Setup (tested on 2020.4)

## Pre-Req
1. Install Nvidia Drivers, Nvidia Cuda Toolkit and docker
`sudo apt-get install nvidia-driver nvidia-cuda-toolkit`
2. Install Nvidia Container Runtime (Follow the steps outlined in thier git if the below do not work)
```
curl -s -L https://nvidia.github.io/nvidia-container-runtime/gpgkey | \
  sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
```
```
curl -s -L https://nvidia.github.io/nvidia-container-runtime/ubuntu20.04/nvidia-container-runtime.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-runtime.list
```
```
sudo apt-get update
sudo apt-get install nvidia-container-runtime docker.io
```
```
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/override.conf <<EOF 
[Service] 
ExecStart= 
ExecStart=/usr/sbin/dockerd --host=fd:// --add-runtime=nvidia=/usr/bin/nvidia-container-runtime
EOF
```
```
sudo systemctl daemon-reload
sudo systemctl restart docker
```
```
ln -s /sbin/ldconfig /sbin/ldconfig.real
```

# Container Setup Notes
## SSL
* If you're wanting to use your own certificates bind mount them to the following locations otherwise they will be generated on the start of the container
  * /root/crackerjack/data/config/http/ssl.pem
  * /root/crackerjack/data/config/http/ssl.crt

## Persistent Data 
* If you are wanting to persist data you need to set your volume mount to /root/crackerjack/data as all persistant data is stored here.

## Crackerjack Settings
* Hashcat executable: /root/hashcat/hashcat
* Rules Path: /root/hashcat/rules
* Wordlist Path: /wordlists [check or modify in start.sh]
* Uploaded Hashes Path: /root/crackerjack/data/uploads

## Helper Scripts
* build.sh - Build the Dockerfile (also stops the container if its currently running)
* start.sh - Starts the container with the default settings
* stop.sh - Stops the container
* shell.sh - Exec into the running container

# Related Repos
* https://github.com/ctxis/crackerjack
* https://github.com/dizcza/docker-hashcat
* https://github.com/NVIDIA/nvidia-container-runtime
