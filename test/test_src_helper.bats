#!./test/libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'


source src/helper.sh
source test/helper.sh
source test/hardcoded_testdata.txt

@test "Checking get_checksum." {
	md5sum=$(get_expected_md5sum_of_gitlab_runner_installer_for_architecture "amd64")
	EXPECTED_OUTPUT="31f2cb520079da881c02ce479c562ae9"
		
	assert_equal "$md5sum" "$EXPECTED_OUTPUT"
}

@test "Checking check_md5_sum." {
	md5sum=$(check_md5_sum "a4eabc0c3e65e7df3a3bb1ccc1adcd9f" "test/static_file_with_spaces.txt")
	EXPECTED_OUTPUT="EQUAL"
		
	assert_equal "$md5sum" "$EXPECTED_OUTPUT"
}