#!/bin/bash
source src/hardcoded_variables.txt

# Determine architecture.
# Source: https://askubuntu.com/questions/189640/how-to-find-architecture-of-my-pc-and-ubuntu
get_architecture() {
	architecture=$(uname -m)
	# TODO: replace with: dpkg --print-architecture and remove if condition
	
	# Parse architecture to what is available for GitLab Runner
	# Source: https://stackoverflow.com/questions/65450286/how-to-install-gitlab-runner-to-centos-fedora
	if [ "$architecture"=="x86_64" ]; then
		architecture=amd64
	fi
	
	echo $architecture
}

check_md5_sum() {
	expected_md5=$1
	REL_FILEPATH=$2
	
	# Read out the md5 checksum of the downloaded social package.
	md5sum=$(sudo md5sum "$REL_FILEPATH")
	
	# Extract actual md5 checksum from the md5 command response.
	md5sum_head=${md5sum:0:32}
	
	# Assert the measured md5 checksum equals the hardcoded md5 checksum of the expected file.
	#assert_equal "$md5_of_social_package_head" "$TWRP_MD5"
	if [ "$md5sum_head" == "$expected_md5" ]; then
		echo "EQUAL"
	else
		echo "NOTEQUAL"
	fi
}

get_expected_md5sum_of_gitlab_runner_installer_for_architecture() {
	arch=$1
	if [ "$arch" == "amd64" ]; then
		echo $x86_64_runner_checksum
	else
		echo "ERROR"
	fi
}


get_gitlab_package() {
	architecture=$(dpkg --print-architecture)
	if [ "$architecture" == "amd64" ]; then
		echo "$gitlab_default_package"
	elif [ "$architecture" == "armhf" ]; then
		echo "$gitlab_raspberry_package"
	fi
}

downoad_website_source() {
	site=$1
	output_path=$2
	
	echo "site=$site"
	echo "output_path=$output_path"
	
	#bash <(curl -s -N --header "PRIVATE-TOKEN: TOKEN" https://gitlab.com/PATH)
	output=$(curl "$site" > "$output_path")
	echo "output=$output"
}


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