#!/bin/bash
source src/install_and_boot_gitlab_server.sh
source src/install_and_boot_gitlab_runner.sh
source src/run_ci_job.sh
source src/uninstall_gitlab_runner.sh
source src/helper.sh
source src/hardcoded_variables.txt

./uninstall_gitlab.sh -h -r -y

install_and_run_gitlab_server

arch=$(get_architecture)
	
# Run the GitLab runner service installer completely
if [ $(gitlab_runner_is_running $arch) == "NOTRUNNING" ]; then
	get_runner_package $arch
	read -p "ran get_runner_package" >&2
	install_package $arch
	read -p "ran xinstall_package" >&2
	#register_gitlab_runner
	#read -p "ran register_gitlab_runner" >&2
	#create_gitlab_ci_user
	#read -p "ran create_gitlab_ci_user" >&2
	#install_gitlab_runner_service
	#read -p "ran install_gitlab_runner_service" >&2
	#start_gitlab_runner_service
	#read -p "ran start_gitlab_runner_service" >&2
fi

# Get GitLab Runner status:
status=$(sudo gitlab-runner status)
read -p "status=$status" >&2