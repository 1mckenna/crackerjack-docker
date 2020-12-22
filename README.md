# Crackerjack-Docker
A docker container for [Crackerjack (Web Interface for hashcat)](https://github.com/ctxis/crackerjack)

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
## Useful Environment Variables
You can modify the default host and port crackerjack is served on by passing in the below environment variables when you start the container.

| **Environment Variable** | **Comment** | **Default Value**
| :------------------------- | :--------------------: |:---------------:|
| NGINX_HOST                 | Used to set the nginx server_name value| 127.0.0.1         |
| NGINX_PORT                 | Used to set the port being exposed on the docker frontend | 4433               |
| CERTSUBJECT                | Used to set the certificate subject to something other than the default| /C=US/O=Crackerjack/CB=crackerjack.lan |
| TRAEFIK_ENABLED            | Used to enable the reverse proxy setup in the entrypoint.sh script.</br>Please modify the start.sh script if using this option| unset |


## SSL
* If you're wanting to use your own certificates bind mount them to the following locations otherwise they will be generated on the start of the container
  * /root/crackerjack/data/config/http/ssl.pem
  * /root/crackerjack/data/config/http/ssl.crt

## SSL via Reverse Proxy (i.e. traefik)
* If you're planning to utilize a reverse proxy to serve the application, this can be easily done by modifying the start.sh script to comment out the standard configuration and uncomment the related variables and dockerCMD under the Reverse Proxy Section (sample values have been left as an example).
* The logs for gunicorn are being logged to /var/log/gunicorn.log inside the container if you're wanting to bind mount them.
  * Additionally, you can customize the logging by modifyng entrypoint.sh and rerunning build.sh

## Persistent Data 
* If you are wanting to persist data you need to set your volume mount to /root/crackerjack/data as all persistant data is stored here.
  * `docker volume create crackerjack`
  * Then ensure to mount the volume to the container via the following docker option `--mount source=crackerjack,target=/root/crackerjack/data`

## Crackerjack Web App Settings
| **Setting** | **Setting Location** | **Suggested Value**
| :------------------------- | :--------------------: |:---------------:|
| Hashcat Executable Path| Settings &#8594; Admin Settings &#8594; Hashcat | /root/hashcat/hashcat |
| Hashcat Rules Path | Settings &#8594; Admin Settings &#8594; Hashcat | /root/hashcat/rules |
| Wordlist Path | Settings &#8594; Admin Settings &#8594; Settings | /wordlists </br>(Modify start.sh if changing) |
| Upload Path | Settings &#8594; Admin Settings &#8594; Settings | /root/crackerjack/data/uploads |

## Helper Scripts
* build.sh - Build the Dockerfile (also stops and removes the container if its currently running)
* start.sh - Runs or Starts the container, additionally will prompt for container removal if it already exists.
* stop.sh - Stops and asks if you would like to remove the container
* shell.sh - Exec into the running container

## TLDR Setup
If you have not yet gotten the nvidia container runtime setup please see the Setup Nvidia Docker Environment section first.

```
git clone https://github.com/1mckenna/crackerjack-docker.git
cd crackerjack-docker
docker volume create crackerjack
./build.sh
./start.sh
```

# Based off the work here
* Crackerjack (https://github.com/ctxis/crackerjack)
* Hashcat Docker(https://github.com/dizcza/docker-hashcat)

# Related Repo
* https://github.com/NVIDIA/nvidia-container-runtime
