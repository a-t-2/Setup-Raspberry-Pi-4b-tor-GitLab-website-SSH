server_soft_flag=''
server_hard_flag=''
server_hard_yes_flag=''
runner_flag=''

#verbose='false'

print_usage() {
  printf "\nUsage: write:"
  printf "\n\n ./uninstall -s\n to do a soft uninstall of the GitLab server (preserves repositories etc.)."
  printf "\n./uninstall -h\n to do a hard uninstallation and removal of the GitLab server (DELETES repositories, user accounts etc.)."
  printf "\n./uninstall -y\n to do a hard uninstallation and removal of the GitLab server without prompting for confirmation (DELETES repositories, user accounts etc.)."
  printf "\n./uninstall -r \n to uninstall the GitLab runners,"
  printf "\n./uninstall -s -r \n to uninstall the GitLab server and runners.\n"
  printf "you can also combine the separate arguments in different orders, e.g. -r -y -h etc.\n\n"
}

while getopts 'shyr' flag; do
  case "${flag}" in
    s) server_soft_flag='true' ;;
    h) server_hard_flag='true' ;;
    y) server_hard_yes_flag='true' ;;
    r) runner_flag='true' ;;
    *) print_usage
       exit 1 ;;
  esac
done

#echo "server_soft_flag=$server_soft_flag";
#echo "server_hard_flag=$server_hard_flag";
#echo "server_hard_yes_flag=$server_hard_yes_flag";
#echo "runner_flag=$runner_flag";

source src/uninstall_gitlab_server.sh
source src/uninstall_gitlab_runner.sh
source src/hardcoded_variables.txt

## argument parsing logic:
if [ "$server_hard_yes_flag" == "true" ] && [ "$server_soft_flag" == "true" ]; then
	echo "ERROR, you chose to manually override the prompt for the soft uninstallation, but the soft uninstallation does not not prompt for confirmation."
	exit 1
fi
#echo "done"

# arguments:
# TODO: check if the GitLab server is already running.
#uninstall_gitlab_runner
#uninstall_gitlab_server



#source src/install_and_run_gitlab_runner.sh
#$(install_gitlab_runner amd64)

# TODO: 
# call the script that installs tor and ssh for the username
# ensure the docker id is gotten correctly.
# set the gitlab root password at the creation of the GitLab server
# call the gitlab runner installation
# Create a cronjob that starts the tor ssh service at startup
# TODO: remove the infintely growing list of responses in the tor_ssh script
# TODO; get a quick test to check if the gitlab server is up.
# TODO: get a quick test to check if the gitlab runner is up.
# TODO: reboot the device if the Gitlab server is down.
# TODO: reboot the device if the Gitlab runner is down.
