#!./test/libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'
load 'libs/bats-file/load'

source src/boot_tor.sh
source src/helper.sh


@test "Test if the deploy function correctly sets up the GitLab server in less than $SERVER_STARTUP_TIME_LIMIT seconds." {
	# TODO: move uninstallation and deploy_gitlab function to: beforeAll.
	# uninstall the GitLab server and runners.
	#run bash -c "./uninstall_gitlab.sh -h -r -y"
	
	# install the gitlab runner using the gitlab deploy script
	run bash -c "source src/boot_tor.sh && run_deployment_script_for_n_seconds $SERVER_STARTUP_TIME_LIMIT"
	
	
	actual_output=$(gitlab_server_is_running | tail -1) 
	expected_output="RUNNING"
	assert_equal "$actual_output" "$expected_output"
}


@test "Test if the deploy function correctly sets up the GitLab runner in less than $SERVER_STARTUP_TIME_LIMIT seconds." {
	# Assumes the previous test has uninstalled the GitLab server and ran the deploy_gitlab method.
	
	actual_output=$(gitlab_runner_is_running | tail -1) 
	expected_output="RUNNING"
	assert_equal "$actual_output" "$expected_output"
}
