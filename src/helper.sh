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
		echo "$GITLAB_DEFAULT_PACKAGE"
	elif [ "$architecture" == "armhf" ]; then
		echo "$GITLAB_RASPBERRY_PACKAGE"
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

lines_contain_string() {
	STRING=$1
	eval lines=$2
	if [[ $lines =~ "$STRING" ]]; then
		echo "FOUND"; 
	else
		echo "NOTFOUND";
	fi
}


get_line_nr() {
	eval STRING="$1"
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

get_first_line_containing_substring() {
	eval REL_FILEPATH="$1"	
	eval identification_str="$2"
	
	# Get line containing <code id="registration_token">
	if [ "$(file_contains_string "$identification_str_p1" "$REL_FILEPATH")" == "FOUND" ]; then
		line_nr=$(get_line_nr "\${identification_str}" $REL_FILEPATH)
		line=$(get_line_by_nr $line_nr $REL_FILEPATH)
		echo "$line"
	else
		# TODO: raise error
		echo "ERROR"
	fi
}


get_lhs_of_line_till_character() {
	line=$1
	character=$2
	
	# TODO: implement
	lhs="gitlab/gitlab-ce"
	lhs="gitlab-ce"
	lhs="gitlab-ce:latest"
	echo $lhs
}

get_rhs_of_line_till_character() {
	line=$1
	character=$2
	
	# TODO: implement
	rhs="gitlab-ce:latest"
	rhs="gitlab\/gitlab-ce:latest"
	echo $rhs
}

get_docker_container_id_of_gitlab_server() {
	
	log_filepath=$LOG_LOCATION"docker_container.txt"
	gitlab_package=$(get_gitlab_package)
		
	# TODO: select gitlab_package substring rhs up to / (the sed command does not handle this well)
	# TODO: OR replace / with \/ (that works)
	identification_str=$(get_rhs_of_line_till_character "$gitlab_package" "/")
	echo "identification_str=$identification_str"
	# write output to file
	output=$(sudo docker ps -a > $log_filepath)
	
	# get line with "gitlab/gitlab-ce:latest" (package name depending on architecture).
	line=$(get_first_line_containing_substring "$log_filepath" "\${identification_str}")
	echo "line=$line"
	
	#get the container id from the first n characters of the line.
	#container_id=$line[:12]
	#container_id=$line{12}
	
	# TODO: select container_id substring up to character "space"
	container_id=$(get_lhs_of_line_till_character "$line" " ")
	#container_id=$line
	
	# delete the file as cleanup if it exist
	if [ -f "$log_filepath" ] ; then
	    rm "$log_filepath"
	fi
	
	echo $container_id
}