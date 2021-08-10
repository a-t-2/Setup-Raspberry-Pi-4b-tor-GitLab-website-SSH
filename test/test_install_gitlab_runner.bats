#!./test/libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

source src/install_gitlab_runner.sh
source src/helper.sh
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

@test "Checking get package." {
	architecture=$(get_architecture)
	COMMAND_OUTPUT=$(get_runner_package "$architecture")
	EXPECTED_OUTPUT=""
	
	# TODO: check if file is curled
	# TODO: add file to gitignore
	# TODO:  checksum
	assert_equal "$COMMAND_OUTPUT" "$EXPECTED_OUTPUT"
}


@test "Checking installer." {
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

@test "Checking get_checksum." {
	md5sum=$(get_expected_md5sum_for_architecture "amd64")
	EXPECTED_OUTPUT="31f2cb520079da881c02ce479c562ae9"
		
	assert_equal "$md5sum" "$EXPECTED_OUTPUT"
}

@test "Checking check_md5_sum." {
	md5sum=$(check_md5_sum "a4eabc0c3e65e7df3a3bb1ccc1adcd9f" "test/static_file_with_spaces.txt")
	EXPECTED_OUTPUT="EQUAL"
		
	assert_equal "$md5sum" "$EXPECTED_OUTPUT"
}