server_flag='false'
wait_flag='false'
runner_flag='false'

#verbose='false'

print_usage() {
  printf "\nUsage: write:"
  printf "\n\n ./install_gitlab -s\n to do an installation of the GitLab server."
  printf "\n./install_gitlab -r\n to do an installation of the GitLab runner."
  printf "\n./install_gitlab -w\n to do an installation of the GitLab runner that waits untill the GitLab server is running."
  printf "\n./install_gitlab -s -r \n to install the GitLab server and runner.\n"
  printf "you can also combine the separate arguments in different orders, e.g. -r -s -w.\n\n"
}

while getopts 'srw' flag; do
  case "${flag}" in
    s) server_flag='true' ;;
    r) runner_flag='true' ;;
	w) wait_flag='true' ;;
    *) print_usage
       exit 1 ;;
  esac
done

source src/install_and_boot_gitlab_server.sh
source src/install_and_boot_gitlab_runner.sh
source src/helper.sh
source src/hardcoded_variables.txt

## argument parsing logic:
if [ "$server_flag" == "true" ]; then
	install_and_run_gitlab_server
	echo "Installed gitlab server, should be up in a few minutes."
fi

# Check if runner is being uninstalled:
if [ "$runner_flag" == "true" ] && [ "$wait" == "false" ]; then
	# Test if the gitlab server is running
	if [ $(gitlab_server_is_running | tail -1) == "RUNNING" ]; then
		install_and_run_gitlab_runner
	else
		echo "ERROR, tried to start GitLab runner directly without the GitLab server running."
		exit 1
	fi
fi

if [ "$runner_flag" == "true" ] && [ "$wait" == "true" ]; then
	# Test if the gitlab server is running
	if [ $(gitlab_server_is_running | tail -1) == "RUNNING" ]; then
		install_and_run_gitlab_runner
	else
		# Check if the command is given to start the GitLab server recently
		
		started_server_n_sec_ago=$(started_less_than_n_seconds_ago $SERVER_TIMESTAMP_FILEPATH $SERVER_STARTUP_TIME_LIMIT)
		echo "The gitlab server is not running. started_server_n_sec_ago=$started_server_n_sec_ago"
		if [ "$started_server_n_sec_ago" == "YES" ]; then
			if [ $(check_for_n_seconds_if_gitlab_server_is_running $SERVER_STARTUP_TIME_LIMIT | tail -1) == "RUNNING" ]; then
				install_and_run_gitlab_runner
			else
				echo "ERROR, the GitLab service should have started and the waiting function should have returned RUNNING, but it did not."
				exit 1
			fi
		else
			echo "ERROR, tried to start GitLab runner directly without the GitLab server running."
			exit 1
		fi
	fi
fi

# TODO: 
# call the script that installs tor and ssh for the username
# Create a cronjob that starts the tor ssh service at startup
# TODO: remove the infintely growing list of responses in the tor_ssh script
# TODO: reboot the device if the Gitlab server is down.
# TODO: reboot the device if the Gitlab runner is down.