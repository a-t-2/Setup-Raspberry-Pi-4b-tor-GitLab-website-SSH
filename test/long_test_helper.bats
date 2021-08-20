#!./test/libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'
load 'libs/bats-file/load'

source src/helper.sh

@test "If error is thrown if the GitLab server is not running within 5 seconds after uninstallation." {
	# uninstall the GitLab server and runners.
	run bash -c "./uninstall_gitlab.sh -h -r -y"
	
	# Specify how long to test/wait on the GitLab server to get up and running
	duration=4
		
	# run the tested method
	run bash -c "source src/helper.sh && check_for_n_seconds_if_gitlab_server_is_running $duration"
	assert_failure 
	#check_for_n_seconds_if_gitlab_server_is_running
	assert_output --partial "ERROR, did not find the GitLab server running within $duration seconds!"
}


@test "Test if the function correctly identifies that the GitLab server is running within 300 seconds after installation." {
	# uninstall the GitLab server and runners.
	run bash -c "./uninstall_gitlab.sh -h -r -y"
	# install the gitlab runner
	run bash -c "./install_gitlab.sh -s"
	
	# Specify how long to test/wait on the GitLab server to get up and running
	duration=300
		
	# run the tested method
	run bash -c "source src/helper.sh && check_for_n_seconds_if_gitlab_server_is_running $duration"
	
	actual_output=$(gitlab_server_is_running | tail -1) 
	expected_output="RUNNING"
	assert_equal "$actual_output" "$expected_output"
}