#!./test/libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'
load 'libs/bats-file/load'

source src/get_gitlab_server_runner_token.sh
source src/hardcoded_variables.txt

@test "Checking if the gitlab runner registration token is obtained correctly." {
	
	get_registration_token_with_python
	actual_result=$(cat $RUNNER_REGISTRATION_TOKEN_FILEPATH)
	EXPECTED_OUTPUT="somecode"

	assert_file_exist $RUNNER_REGISTRATION_TOKEN_FILEPATH
	assert_equal ${#actual_result}   20
}