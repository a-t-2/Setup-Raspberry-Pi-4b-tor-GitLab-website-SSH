#!/bin/bash
# Get port to run on
# Check if GitLab server is already running on that port. # If yes:
	# Echo already running.
# If no:
	# Check if GitLab is already installed. # If yes:
		# Run command to host GitLab server
	# If no:
		# Install GitLab
		# Run command to host GitLab server

# Install docker:
yes | sudo apt install docker
yes | sudo apt install docker-compose


## Extra commands:
sudo systemctl stop docker
sudo systemctl start docker

# Delete all existing gitlab containers
# 0. First clear all relevant containres using their NAMES:
sudo docker ps -a
sudo docker stop gitlab
sudo docker rm gitlab

sudo docker stop gitlab-redis
sudo docker rm gitlab-redis

sudo docker stop gitlab-postgresql
sudo docker rm gitlab-postgresql

sudo docker stop distracted_kalam
sudo docker rm distracted_kalam

sudo docker stop gitlab/gitlab-ce:latest
sudo docker rm gitlab/gitlab-ce:latest

# remove all containers
sudo docker rm -f $(sudo docker ps -aq)

# Verify all relevant containers are deleted:
sudo docker ps -a

# stop ngix service
sudo service apache2 stop
sudo service nginx stop
sudo nginx -s stop

# Run docker installation command of gitlab

architecture=$(dpkg --print-architecture)
if [ "$architecture" == "amd64" ]; then
	sudo docker run --detach \
	  --hostname 127.0.0.1 \
	  --publish 443:443 --publish 80:80 --publish 23:22 \
	  --name gitlab \
	  --restart always \
	  --volume $GITLAB_HOME/config:/etc/gitlab \
	  --volume $GITLAB_HOME/logs:/var/log/gitlab \
	  --volume $GITLAB_HOME/data:/var/opt/gitlab \
	  gitlab/gitlab-ce:latest
elif [ "$architecture" == "armhf" ]; then
	sudo docker run --detach \
	  --hostname 127.0.0.1 \
	  --publish 443:443 --publish 80:80 --publish 23:22 \
	  --name gitlab \
	  --restart always \
	  --volume $GITLAB_HOME/config:/etc/gitlab \
	  --volume $GITLAB_HOME/logs:/var/log/gitlab \
	  --volume $GITLAB_HOME/data:/var/opt/gitlab \
	  ulm0/gitlab
fi

  
# go to:
#localhost
# set password
# login with account name:
#root
# and the password you just set.
 
## Trouble shooting
# If it returns:
#Error response from daemon: driver failed programming external connectivity on endpoint gitlab (<somelongcode>): Error starting userland proxy: listen tcp4 0.0.0.0:22: bind: address already in use.
# run:
#sudo lsof -i -P -n | grep 22
# identify which process nrs are running on port 22, e.g.:
#sshd      1234     root    3u  IPv4  23423      0t0  TCP *:22 (LISTEN)
# then kill all those processes
#sudo kill 1234
# then run this script again.

# You can check how long it takes before the gitlab server is completed running with:
#sudo docker logs -f gitlab
