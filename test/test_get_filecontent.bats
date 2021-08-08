#!./test/libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

source src/ssh_tor.sh

@test "Checking if last three lines without spaces are returned." {
	COMMAND_OUTPUT=$(get_last_n_lines_without_spaces "3" "test/samplefile_without_spaces.txt")
	EXPECTED_OUTPUT="firstline secondline thirdline"
		
	assert_equal "$COMMAND_OUTPUT" "$EXPECTED_OUTPUT"
}

@test "Checking if last three lines with spaces are returned." {
	COMMAND_OUTPUT=$(get_last_n_lines_without_spaces "3" "test/samplefile_with_spaces.txt")
	EXPECTED_OUTPUT="first line second line third line"
		
	assert_equal "$COMMAND_OUTPUT" "$EXPECTED_OUTPUT"
}


@test "Checking if a line with a space is found by a function." {
	COMMAND_OUTPUT=$(file_contains_string "second line" "test/samplefile_with_spaces.txt")
	EXPECTED_OUTPUT="FOUND"
		
	assert_equal "$COMMAND_OUTPUT" "$EXPECTED_OUTPUT"
}

@test "Checking if a line the file_contains_string function does not return a false positive (double space)." {
	COMMAND_OUTPUT=$(file_contains_string "second  line" "test/samplefile_with_spaces.txt")
	EXPECTED_OUTPUT="NOTFOUND"
		
	assert_equal "$COMMAND_OUTPUT" "$EXPECTED_OUTPUT"
}


@test "Check if the correct line number is returned for first line." {
	COMMAND_OUTPUT=$(get_line_nr "first line" "test/samplefile_with_spaces.txt")
	EXPECTED_OUTPUT="1"
		
	assert_equal "$COMMAND_OUTPUT" "$EXPECTED_OUTPUT"
}

@test "Check if the correct line number is returned for second line." {
	COMMAND_OUTPUT=$(get_line_nr "second line" "test/samplefile_with_spaces.txt")
	EXPECTED_OUTPUT="2"
		
	assert_equal "$COMMAND_OUTPUT" "$EXPECTED_OUTPUT"
}

@test "Check if the correct line number is returned for third line." {
	COMMAND_OUTPUT=$(get_line_nr "third line" "test/samplefile_with_spaces.txt")
	EXPECTED_OUTPUT="3"
		
	assert_equal "$COMMAND_OUTPUT" "$EXPECTED_OUTPUT"
}


@test "Checking if hello is returned." {
	COMMAND_OUTPUT=$(echo_hello)
	EXPECTED_OUTPUT="hello"
		
	assert_equal "$COMMAND_OUTPUT" "$EXPECTED_OUTPUT"
}

@test "Checking if hello and ttwo input arguments are returned." {
	COMMAND_OUTPUT=$(echo_hello_input "hi" "test/samplefile.txt")
	EXPECTED_OUTPUT="hellohitest/samplefile.txt"
		
	assert_equal "$COMMAND_OUTPUT" "$EXPECTED_OUTPUT"
}