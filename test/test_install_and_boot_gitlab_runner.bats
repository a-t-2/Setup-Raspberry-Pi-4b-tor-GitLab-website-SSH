#!./test/libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

source src/install_and_run_gitlab_runner.sh
#source src/helper.sh
source test/helper.sh
source test/hardcoded_testdata.txt

# Method that executes all tested main code before running tests.
setup() {
	# print test filename to screen.
	if [ "${BATS_TEST_NUMBER}" = 1 ];then
		echo "# Testfile: $(basename ${BATS_TEST_FILENAME})-" >&3
	fi
	
	#ans=$(create_file_with_three_lines_with_spaces)
	#ans=$(create_file_with_three_lines_without_spaces)
}


#TODO: test if the install_gitlab_runner() { returns error if an unsupported architecture is included.

	
@test "Verifying the downloading of the GitLab Runner installer package." {
	architecture=$(get_architecture)
	COMMAND_OUTPUT=$(get_runner_package "$architecture")
	EXPECTED_OUTPUT=""
	
	assert_equal "$COMMAND_OUTPUT" "$EXPECTED_OUTPUT"
}
# TODO: test if file is curled (exists)
# TODO: test if the file is made runnable
# TODO: test md5sum (is correct)


@test "Checking if GitLab Runner installation was succesfull." {
	architecture=$(get_architecture)
	COMMAND_OUTPUT=$(install_package "$architecture")
	EXPECTED_OUTPUT=""
	
	# actual expected output
	#filename=gitlab-runner_amd64.deb
	#install=Selecting previously unselected package gitlab-runner.
	#(Reading database ... 513537 files and directories currently installed.)
	#Preparing to unpack gitlab-runner_amd64.deb ...
	#Unpacking gitlab-runner (14.1.0) ...
	#Setting up gitlab-runner (14.1.0) ...
	#GitLab Runner: creating gitlab-runner...
	#Home directory skeleton not used
	#
	#Check and remove all unused containers (both dangling and unreferenced) including volumes.
	#------------------------------------------------------------------------------------------
	#
	#
	#Total reclaimed space: 0B

	
	assert_equal "$COMMAND_OUTPUT" "$EXPECTED_OUTPUT"
}
# TODO: inspect several lines of the installation are found.
# TODO: distinguish between output when the package is not, and is installed.


@test "Check if GitLab Runner was succesfully registered with the GitLab server." {
	md5sum=$(register_gitlab_runner)
	EXPECTED_OUTPUT="EQUAL"
		
	assert_equal "$md5sum" "$EXPECTED_OUTPUT"
}
# TODO: determine how one can verify whether the GitLab Runner is indeed verified at the GitLab server.


@test "Verify a sudo user account is created for the GitLab Runner CI." {
	md5sum=$(create_gitlab_ci_user)
	EXPECTED_OUTPUT="EQUAL"
		
	assert_equal "$md5sum" "$EXPECTED_OUTPUT"
}
# TODO: determine how one can verify whether a sudo user account is created for the GitLab Runner CI


@test "Verify the GitLab Runner CI service is installed correctly." {
	md5sum=$(install_gitlab_runner_service)
	EXPECTED_OUTPUT="EQUAL"
		
	assert_equal "$md5sum" "$EXPECTED_OUTPUT"
}
# TODO: determine how one can verify whether the GitLab Runner CI service is installed correctly.


@test "Test if the GitLab Runner CI service is started correctly." {
	md5sum=$(start_gitlab_runner_service)
	EXPECTED_OUTPUT="EQUAL"
		
	assert_equal "$md5sum" "$EXPECTED_OUTPUT"
}
# TODO: determine how one can verify whether the GitLab Runner CI service is started correctly.


@test "Test if the GitLab Runner CI service is running correctly." {
	run_service_output=$(run_gitlab_runner_service)
	EXPECTED_OUTPUT="service is running"
		
	assert_equal "$run_service_output" "$EXPECTED_OUTPUT"
}
# TODO: determine how one can verify whether the GitLab Runner CI service is running correctly.