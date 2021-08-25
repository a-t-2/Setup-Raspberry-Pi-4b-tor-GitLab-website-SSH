#!./test/libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'
load 'libs/bats-file/load'

source src/install_and_boot_gitlab_server.sh
source src/install_and_boot_gitlab_runner.sh
source src/hardcoded_variables.txt

# Method that executes all tested main code before running tests.
#setup() {
#	# print test filename to screen.
#	if [ "${BATS_TEST_NUMBER}" = 1 ];then
#		echo "# Testfile: $(basename ${BATS_TEST_FILENAME})-" >&3
#	fi
#
#	# Uninstall GitLab Runner and GitLab Server
#	run bash -c "./uninstall_gitlab.sh -h -r -y"
#
#	# Install GitLab Server
#	install_and_run_gitlab_server
#
#	# Verify GitLab server is running
#
#	# Install GitLab runner
#	#install_and_run_gitlab_server
#}


@test "Not different." {
	assert_equal "Same" "Same"
}

@test "Verify that the GitLab server is running within 300." {
	#source src/helper.sh && check_for_n_seconds_if_gitlab_server_is_running "300"
	is_running=$(check_for_n_seconds_if_gitlab_server_is_running "300")
	assert_equal "$is_running" "RUNNING"
}