#!/bin/bash

## Description
# This script sets up a tor connection. Once the tor connection is established, 
# it starts monitoring whether the tor connection is maintained. 
# If the tor-connection is dropped, it automatically kills the two jobs that are created
# WITHIN this script. (jobs can only be created in a single shell, not from one script/shell to the other)
# The first job is the tor_connection job. The second job is currently unidentified.
# Note. This is not a script that calls other scripts and services, it only maintains a tor connection.


## Usage
# Set up this script as a crondjob with the following commands(first put it in the ~/startup/` folder):
# sudo crontab -e
# @reboot bash /home/ubuntu/startup/torssh.sh >1 /dev/null 2> /home/ubuntu/startup/some_job.er


source src/install_and_boot_gitlab_server.sh
source src/install_and_boot_gitlab_runner.sh

# TODO: verify the reboot script is executable, otherwise throw a warning

# TODO: verify the tor script and sites have been deployed before proceeding, send message otherwise
echo "To get the onion domain to ssh into, run:"
echo "sudo cat /var/lib/tor/other_hidden_service/hostname"

get_tor_status() {
	tor_status=$(curl --socks5 localhost:9050 --socks5-hostname localhost:9050 -s https://check.torproject.org/ | cat | grep -m 1 Congratulations | xargs)
	echo $tor_status
}

connect_tor() {
	tor_connection=$(nohup sudo tor > sudo_tor.out &)
	sleep 10
	echo $tor_connection
}

start_gitlab_server() {
	$(install_and_run_gitlab_server)
}

start_gitlab_runner() {
	$(install_and_run_gitlab_runner)
}

deploy_gitlab() {
	# assume this function is called every minute or so
	# Check if GitLab server is running, if no: 
		# Check if GitLab server has been started in the last 15 minutes, if yes:
			# wait
		# Check if GitLab server has been started in the last 15 minutes, if no:
			# start GitLab server
			
	# Check if GitLab server is running, if yes: 
		# Check if GitLab runner is running, if yes:
			# pass
		# Check if GitLab runner is running, if no:
			# Check if GitLab server has been started in the last 5 minutes, if yes:
				# wait
			# Check if GitLab server has been started in the last 5 minutes, if no:
				# start GitLab runner
}

# Start infinite loop that keeps system connected to vpn
while [ "false" == "false" ]
do
	# Get tor connection status
	tor_status_outside=$(get_tor_status)
	echo "tor_status_outside=$tor_status_outside" >&2
	sleep 1
	
	# Reconnect tor if the system is disconnected
	if [[ "$tor_status_outside" != *"Congratulations"* ]]; then
		echo "Is Disconnected"
		# Kill all jobs
		jobs -p | xargs -I{} kill -- -{}
		sudo killall tor
		tor_connections=$(connect_tor)
		
		deploy_gitlab
		
	elif [[ "$tor_status_outside" == *"Congratulations"* ]]; then
		echo "Is connected"
		
		# Verify the correct amount of jobs are running
		if [ `jobs|wc -l` == 2 ]
			then
			echo 'There are TWO jobs'
		else
			echo 'There are NOT CORRECT AMOUNT OF jobs'
			# Kill all jobs
			jobs -p | xargs -I{} kill -- -{}
			# restart jobs
			echo "Killed all jobs"
			sleep 6 &
			echo "\n\n\n Job 1"
			sleep 5 &
			echo "started Job 2"
		fi
		
		# Start GitLab service
		#$(start_gitlab_service)
		#$(start_gitlab_runner)
	fi
done