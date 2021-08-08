#!/bin/bash
# Sets up SSH over tor and helps you copy the onion address 
# at which you can ssh into this RPI to your host device/pc. 

get_last_n_lines_without_spaces() {
	number=$1
	abs_path=$2
	
	# get last number lines of file
	last_number_of_lines=$(sudo tail -n "$number" "$abs_path")
	
	# Output true or false to pass the equality test result to parent function
	echo $last_number_of_lines
}

# allows a string with spaces, hence allows a line
file_contains_string() {
	STRING=$1
	REL_FILEPATH=$2
	
	if [[ ! -z $(grep "$STRING" "$REL_FILEPATH") ]]; then 
		echo "FOUND"; 
	else
		echo "NOTFOUND";
	fi
}


get_line_nr() {
	STRING=$1
	REL_FILEPATH=$2
	line_nr=$(awk "/$STRING/{ print NR; exit }" $REL_FILEPATH)
	echo $line_nr
}


echo_hello() {
	echo "hello"
}

echo_hello_input() {
	input=$1
	input_two=$2
	echo "hello$input$input_two"
}