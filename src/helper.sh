#!/bin/bash
source src/hardcoded_variables.txt

# Determine architecture of the machine on which this service is ran.
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

# Checks whether the md5 checkum of the file specified with the incoming filepath
# matches that of an expected md5 filepath that is incoming.
# echo's "EQUAL" if the the expected md5sum equals the measured md5sum
# returns "NOTEQUAL" otherwise.
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


# Computes the md5sum of the GitLab installation file that is being downloaded
# with respect to the expected md5sum of that file. (For safety).
# 
get_expected_md5sum_of_gitlab_runner_installer_for_architecture() {
	arch=$1
	if [ "$arch" == "amd64" ]; then
		echo $x86_64_runner_checksum
	else
		read -p "ERROR, the md5 checksum of the downloaded GitLab installer package does not match the expected md5 checksum, perhaps the download was interrupted."
		exit 1
	fi
}


# Returns the GitLab installation package name that matches the architecture of the device 
# on which it is installed. Not every package/GitLab source repository works on each computer/architecture.
# Currently working GitLab installation packages have only been found for the amd64 architecture and 
# the RaspberryPi 4b architectures have been verified.
get_gitlab_package() {
	architecture=$(dpkg --print-architecture)
	if [ "$architecture" == "amd64" ]; then
		echo "$GITLAB_DEFAULT_PACKAGE"
	elif [ "$architecture" == "armhf" ]; then
		echo "$GITLAB_RASPBERRY_PACKAGE"
	fi
}


# Downloads the source code of an incoming website into a file.
# TODO: ensure/verify curl is installed before calling this method.
downoad_website_source() {
	site=$1
	output_path=$2
	
	output=$(curl "$site" > "$output_path")
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
	#read -p "number=$number"
	#read -p "REL_FILEPATH=$REL_FILEPATH"
	the_line=$(sed "${number}q;d" $REL_FILEPATH)
	echo $the_line
}

get_first_line_containing_substring() {
	# Returns the first line in a file that contains a substring, silent otherwise.
	eval REL_FILEPATH="$1"
	eval identification_str="$2"
	
	# Get line containing <code id="registration_token">
	if [ "$(file_contains_string "$identification_str" "$REL_FILEPATH")" == "FOUND" ]; then
		line_nr=$(get_line_nr "\${identification_str}" $REL_FILEPATH)
		if [ "$line_nr" != "" ]; then
			#read -p "ABOVE and line_nr=$line_nr"
			line=$(get_line_by_nr $line_nr $REL_FILEPATH)
			#read -p "BELOW"
			echo "$line"
		else
			#read -p "ERROR, did find the string in the file but did not find the line number, identification str =\${identification_str} And filecontent=$(cat $REL_FILEPATH)"
			#exit 1
			pass
		fi
	else
		#read -p "ERROR, did not find the string in the file identification str =\${identification_str} And filecontent=$(cat $REL_FILEPATH)"
		#exit 1
		pass
	fi
}


get_lhs_of_line_till_character() {
	line=$1
	character=$2
	
	# TODO: implement
	#lhs=${line%$character*}
	#read -p "line=$line"
	#read -p "character=$character"

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
	# echo's the Docker container id if it is found, silent otherwise.
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
	#read -p "CONFIRM BELOW in, container_id=$container_id"

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
	##read -p "CONFIRM ABOVE check"
	container_id=$(get_docker_container_id_of_gitlab_server)
	#read -p "CONFIRM BELOW check and container_id=$container_id"
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
	#echo "duration=$duration"
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