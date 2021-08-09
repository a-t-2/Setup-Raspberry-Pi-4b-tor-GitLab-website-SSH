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


@test "Check if the correct line is returned for line number one." {
	COMMAND_OUTPUT=$(get_line_by_nr "1" "test/samplefile_with_spaces.txt")
	EXPECTED_OUTPUT="first line"
		
	assert_equal "$COMMAND_OUTPUT" "$EXPECTED_OUTPUT"
}

@test "Check if the correct line is returned for line number two." {
	COMMAND_OUTPUT=$(get_line_by_nr "2" "test/samplefile_with_spaces.txt")
	EXPECTED_OUTPUT="second line"
		
	assert_equal "$COMMAND_OUTPUT" "$EXPECTED_OUTPUT"
}

@test "Check if the correct line is returned for line number three." {
	COMMAND_OUTPUT=$(get_line_by_nr "3" "test/samplefile_with_spaces.txt")
	EXPECTED_OUTPUT="third line"
		
	assert_equal "$COMMAND_OUTPUT" "$EXPECTED_OUTPUT"
}


@test "Check if the correct line number is returned for first line." {
	COMMAND_OUTPUT=$(get_line_nr "first line" "test/samplefile_with_spaces.txt")
	EXPECTED_OUTPUT="1"
		
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


@test "Check if three arguments are read correctly." {
	COMMAND_OUTPUT=$(read_three_args "first line"  "second line" "third line" "fourth line")
	EXPECTED_OUTPUT="arg4=fourth line"
		
	assert_equal "$COMMAND_OUTPUT" "$EXPECTED_OUTPUT"
}


@test "Check if three arguments are read correctly." {
	first_line="second line"
	second_line="third line"
	REL_FILEPATH="test/samplefile_with_spaces.txt"
	COMMAND_OUTPUT=$(has_two_consecutive_lines "$first_line"  "$second_line" "$REL_FILEPATH")
	EXPECTED_OUTPUT="FOUND"
		
	assert_equal "$COMMAND_OUTPUT" "$EXPECTED_OUTPUT"
}

@test "Check if three arguments are read correctly." {
	first_line="first line"
	second_line="third line"
	REL_FILEPATH="test/samplefile_with_spaces.txt"
	COMMAND_OUTPUT=$(has_two_consecutive_lines "$first_line"  "$second_line" "$REL_FILEPATH")
	EXPECTED_OUTPUT="NOTFOUND"
		
	assert_equal "$COMMAND_OUTPUT" "$EXPECTED_OUTPUT"
}