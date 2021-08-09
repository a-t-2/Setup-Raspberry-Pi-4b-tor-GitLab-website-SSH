#!/bin/bash
# Sets up SSH over tor and helps you copy the onion address 
# at which you can ssh into this RPI to your host device/pc. 

get_last_n_lines_without_spaces() {
	number=$1
	REL_FILEPATH=$2
	
	# get last number lines of file
	last_number_of_lines=$(sudo tail -n "$number" "$REL_FILEPATH")
	
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

get_line_by_nr() {
	number=$1
	REL_FILEPATH=$2
	the_line=$(sed "${number}q;d" $REL_FILEPATH)
	echo $the_line
}

echo_hello() {
	echo "hello"
}

echo_hello_input() {
	input=$1
	input_two=$2
	echo "hello$input$input_two"
}

read_three_args() {
	arg1=$1
	arg2=$2
	arg3=$3
	arg4=$4
	echo "arg4=$arg4"
}

# actual usage:
# 0. Check if the tor configuration file contains the directory used for ssh:
#first_line="HiddenServiceDir $HIDDENSERVICEDIR_SSH$HIDDENSERVICENAME_SSH/"
#second_line_option_I="HiddenServicePort 22"
# Note option 2 is used.
#second_line_option_II="HiddenServicePort 22 127.0.0.1:22"

# Ensure the SSH service is contained in the tor configuration.
has_two_consecutive_lines() {
	first_line=$1
	second_line=$2
	REL_FILEPATH=$3	

	if [ "$(file_contains_string "$first_line" "$REL_FILEPATH")" == "FOUND" ]; then
		if [ "$(file_contains_string "$second_line" "$REL_FILEPATH")" == "FOUND" ]; then
			# get line_nr first_line
			first_line_line_nr="$(get_line_nr "$first_line" "$REL_FILEPATH")"
			
			# get next line number
			next_line_number=$((first_line_line_nr + 1))
			
			# get next line
			next_line=$(get_line_by_nr "$next_line_number" "test/samplefile_with_spaces.txt")
			
			# verify next line equals the second line
			if [ "$next_line" == "$second_line" ]; then
				echo "FOUND"
			else
				echo "NOTFOUND"
			fi			
		fi
	else
		echo "NOTFOUND"
	fi
}

has_either_block_of_two_consecutive_lines() {
	first_line=$1
	second_line_option_I=$2
	second_line_option_II=$3
	REL_FILEPATH=$4
	
	has_first_block=$(has_two_consecutive_lines "$first_line"  "$second_line_option_I" "$REL_FILEPATH")
	#echo "has_first_block=$has_first_block"
	
	has_second_block=$(has_two_consecutive_lines "$first_line"  "$second_line_option_II" "$REL_FILEPATH")
	#echo "has_second_block=$has_second_block"
	if [ "$has_first_block" == "FOUND" ] || [ "$has_second_block" == "FOUND" ]; then
		echo "FOUND"
	else
		echo "NOTFOUND"
	fi
}

# if first_line in file
	# if second line in file
		# get line_nr first_line
		# get next line
		# verify next line equals second_line_option_I or second_line_option_II
		# return true
	# else:
		# raise error
	#fi
# else:
	# append first_line to file
	# append second_line to file
# fi

#last_two_lines=$(sudo tail -n 2 /etc/tor/torrc)
#second_last_line=$(echo $last_two_lines | sudo head -n 1)
#last_line=$(sudo tail -n 1 /etc/tor/torrc)
#if [ "$second_last_line" != "HiddenServiceDir /var/lib/tor/other_hidden_service/" ]; then
#	if [ "$last_line" != "HiddenServicePort 22" ]; then
#		echo 'HiddenServiceDir /var/lib/tor/other_hidden_service/' | sudo tee -a /etc/tor/torrc
#		echo 'HiddenServicePort 22' | sudo tee -a /etc/tor/torrc
#	fi
#fi