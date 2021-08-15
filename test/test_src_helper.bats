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
	md5sum=$(check_md5_sum "a4eabc0c3e65e7df3a3bb1ccc1adcd9f" "test/static_file_with_spaces.txt")
	EXPECTED_OUTPUT="EQUAL"
		
	assert_equal "$md5sum" "$EXPECTED_OUTPUT"
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