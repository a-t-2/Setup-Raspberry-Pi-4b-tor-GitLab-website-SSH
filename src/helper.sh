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
	#lhs=${line%$character*}
	lhs=$(cut -d "$character" -f1 <<< "$line")
	echo $lhs
}

get_rhs_of_line_till_character() {
	# TODO: include space right after character, e.g. return " with" instead of "width" on ": with".
	line=$1
	character=$2
	
	rhs=$(cut -d "$character" -f2- <<< "$line")
	echo $rhs
}


get_docker_container_id_of_gitlab_server() {
	space=" "
	log_filepath=$LOG_LOCATION"docker_container.txt"
	gitlab_package=$(get_gitlab_package)
	
	# TODO: select gitlab_package substring rhs up to / (the sed command does not handle this well)
	# TODO: OR replace / with \/ (that works)
	identification_str=$(get_rhs_of_line_till_character "$gitlab_package" "/")
	
	# write output to file
	output=$(sudo docker ps -a > $log_filepath)
	
	# Get line with "gitlab/gitlab-ce:latest" (package name depending on architecture).
	line=$(get_first_line_containing_substring "$log_filepath" "\${identification_str}")
	#echo "line=$line"
	
	# Get container id of the line containing the id.
	container_id=$(get_lhs_of_line_till_character "$line" "$space")
	
	# delete the file as cleanup if it exist
	if [ -f "$log_filepath" ] ; then
	    rm "$log_filepath"
	fi
	
	echo $container_id
}


visudo_contains() {
	line=$1
	#echo "line=$line"
	visudo_content=$(sudo cat /etc/sudoers)
	#echo $visudo_content
	
	actual_result=$(lines_contain_string "$line" "\${visudo_content}")
	echo $actual_result
}


# gitlab runner status:
check_gitlab_runner_status() {
	status=$(sudo gitlab-runner status)
	echo "$status"
}

# gitlab server status:
#sudo docker exec -i 79751949c099 bash -c "gitlab-rails status"
#sudo docker exec -i 79751949c099 bash -c "gitlab-ctl status"
check_gitlab_server_status() {
	container_id=$(get_docker_container_id_of_gitlab_server)
	#echo "container_id=$container_id"
	status=$(sudo docker exec -i "$container_id" bash -c "gitlab-ctl status")
	echo "$status"
}

gitlab_server_is_running() {
	actual_result=$(check_gitlab_server_status)
	if
	[  "$(lines_contain_string 'run: alertmanager: (pid ' "\${actual_result}")" == "FOUND" ] &&
	[  "$(lines_contain_string 'run: gitaly: (pid ' "\${actual_result}")" == "FOUND" ] &&
	[  "$(lines_contain_string 'run: gitlab-exporter: (pid ' "\${actual_result}")" == "FOUND" ] &&
	[  "$(lines_contain_string 'run: gitlab-workhorse: (pid ' "\${actual_result}")" == "FOUND" ] &&
	[  "$(lines_contain_string 'run: grafana: (pid ' "\${actual_result}")" == "FOUND" ] &&
	[  "$(lines_contain_string 'run: logrotate: (pid ' "\${actual_result}")" == "FOUND" ] &&
    [  "$(lines_contain_string 'run: nginx: (pid ' "\${actual_result}")" == "FOUND" ] &&
    [  "$(lines_contain_string 'run: postgres-exporter: (pid ' "\${actual_result}")" == "FOUND" ] &&
    [  "$(lines_contain_string 'run: postgresql: (pid ' "\${actual_result}")" == "FOUND" ] &&
    [  "$(lines_contain_string 'run: prometheus: (pid ' "\${actual_result}")" == "FOUND" ] &&
    [  "$(lines_contain_string 'run: puma: (pid ' "\${actual_result}")" == "FOUND" ] &&
    [  "$(lines_contain_string 'run: redis: (pid ' "\${actual_result}")" == "FOUND" ] &&
    [  "$(lines_contain_string 'run: redis-exporter: (pid ' "\${actual_result}")" == "FOUND" ] &&
    [  "$(lines_contain_string 'run: sidekiq: (pid ' "\${actual_result}")" == "FOUND" ] &&
    [  "$(lines_contain_string 'run: sshd: (pid ' "\${actual_result}")" == "FOUND" ]
	then
		echo "RUNNING"
	else
		echo "NOTRUNNING"
	fi
}

gitlab_runner_is_running() {
	actual_result=$(check_gitlab_runner_status)
	EXPECTED_OUTPUT="gitlab-runner: Service is running"
	if [ "$actual_result" == "$EXPECTED_OUTPUT" ]; then
		echo "RUNNING"
	else
		echo "NOTRUNNING"
	fi
}

# reconfigure:
#sudo docker exec -i 4544ce711468 bash -c "gitlab-ctl reconfigure"

check_for_n_seconds_if_gitlab_server_is_running() {
	duration=$1
	echo "duration=$duration"
	running="false"
	end=$(("$SECONDS" + "$duration"))
	while [ $SECONDS -lt $end ]; do
		if [ $(gitlab_server_is_running | tail -1) == "RUNNING" ]; then
			echo "RUNNING"; break;
			#echo "RUNNING"
			running="true"
		fi
	done
	if [ "$running" == "false" ]; then
		echo "ERROR, did not find the GitLab server running within $duration seconds!"
		exit 1
	fi
}