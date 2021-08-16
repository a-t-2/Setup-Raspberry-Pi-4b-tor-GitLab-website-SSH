#!./test/libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'


source src/helper.sh
source test/helper.sh
source src/hardcoded_variables.txt
source test/hardcoded_testdata.txt

#@test "Checking get_checksum." {
#	md5sum=$(get_expected_md5sum_of_gitlab_runner_installer_for_architecture "amd64")
#	EXPECTED_OUTPUT="31f2cb520079da881c02ce479c562ae9"
#		
#	assert_equal "$md5sum" "$EXPECTED_OUTPUT"
#}

@test "Checking check_md5_sum." {
	actual_output=$(check_md5_sum "42dbacaf348d3e48e5cde4fe84ef48b3" "test/static_file_with_spaces.txt")
	md5sum=$(sudo md5sum "test/static_file_with_spaces.txt")
	md5sum_head=${md5sum:0:32}
	echo "md5sum_head=$md5sum_head"
	
	EXPECTED_OUTPUT="EQUAL"
		
	assert_equal "$actual_output" "$EXPECTED_OUTPUT"
}


@test "Test download website source code." {
	source_filepath=$LOG_LOCATION$RUNNER_SOURCE_FILENAME
	output=$(downoad_website_source "$GITLAB_SERVER_HTTP_URL" "$source_filepath")
	
	# TODO: delete file if exists
	
	# TODO: change to: https://github.com/ztombol/bats-file
	if [ -f "$source_filepath" ]; then
		assert_equal "file exists"  "file exists"
	else
		assert_equal "The following file does not exist:" "$source_filepath"
	fi 
}


@test "Checking get line containing substring." {
	identification_str="second li"
	#line=$(get_first_line_containing_substring "test/static_file_with_spaces.txt" "$identification_str")
	line=$(get_first_line_containing_substring "test/static_file_with_spaces.txt" "\${identification_str}")
	EXPECTED_OUTPUT="second line"
		
	assert_equal "$line" "$EXPECTED_OUTPUT"
}


@test "Checking docker_container_id." {
	docker_container_id=$(get_docker_container_id_of_gitlab_server)
	EXPECTED_OUTPUT="d5e4001b4d8f"
	
	# TODO: replace hardcoded container id with a `sudo docker ps -a` command
	# that verifies the returned container_id is in the output of that command.
	# (for the given gitlab package/architecture).
		
	assert_equal "$docker_container_id" "$EXPECTED_OUTPUT"
}


@test "Lines contain string." {
	lines=$(printf 'First line\nsecond line \nthird line \n')
	
	contained_substring="second"
	
	actual_result=$(lines_contain_string "$contained_substring" "\${lines}")
	EXPECTED_OUTPUT="FOUND"
		
	assert_equal "$actual_result" "$EXPECTED_OUTPUT"
}


@test "Test get remainder of line starting from the semicolon character." {
	line="some long line: with some spaces in it"
	character=":"
	
	actual_result=$(get_rhs_of_line_till_character "$line" "$character")
	# TODO: make it work with space included.
	#EXPECTED_OUTPUT=" with some spaces in it"
	EXPECTED_OUTPUT="with some spaces in it"
		
	assert_equal "$actual_result" "$EXPECTED_OUTPUT"
}

@test "Test get remainder of line starting from the space character." {
	line="somelongline:withsome spaces in it"
	character=" "
	
	actual_result=$(get_rhs_of_line_till_character "$line" "$character")
	EXPECTED_OUTPUT="spaces in it"
		
	assert_equal "$actual_result" "$EXPECTED_OUTPUT"
}

@test "Test get substring of a line before the semicolon character." {
	line="some long line: with some spaces in it"
	character=":"
	
	actual_result=$(get_lhs_of_line_till_character "$line" "$character")
	EXPECTED_OUTPUT="some long line"
		
	assert_equal "$actual_result" "$EXPECTED_OUTPUT"
}


@test "Test get substring of a line before the spacebar character." {
	line="somelongline:withsome spaces in it"
	character=" "
	
	actual_result=$(get_lhs_of_line_till_character "$line" "$character")
	EXPECTED_OUTPUT="somelongline:withsome"
		
	assert_equal "$actual_result" "$EXPECTED_OUTPUT"
}
