#!/bin/bash
# Source: https://www.youtube.com/watch?v=G8ZONHOTAQk 
# Source: https://docs.gitlab.com/runner/install/
# Source: https://docs.gitlab.com/runner/install/linux-manually.html

source src/helper.sh
source src/hardcoded_variables.txt
source src/gitlab_runner_token.txt

install_gitlab_runner() {
	arch=$1
	# TODO: verify if architecture is supported, raise error if not
	# TODO: Mention that support for the architecture can be gained by
	# downloading the right GitLab Runner installation package and adding
	# its verified md5sum into hardcoded_variables.txt (possibly adding an if statement 
	# to get_architecture().)
	
	if [ $(gitlab_runner_is_running $arch) == "not_running" ]; then
		$(get_runner_package $arch)
		$(install_package $arch)
		$(register_gitlab_runner)
		$(create_gitlab_ci_user)
		$(install_gitlab_runner_service)
		$(start_gitlab_runner_service)
		$(run_gitlab_runner_service)
	fi
}

extract_runner_token_from_source() {
	source_filepath="$LOG_LOCATION$RUNNER_SOURCE_FILENAME"
	identification_str='<code id="registration_token">'
	end_str="</code>"
	
	# Remove old log files if exist
	if [ -f "$source_filepath" ] ; then
	    rm "$source_filepath"
	fi
	
	# download website
	get_website=$(downoad_website_source "$GITLAB_SERVER" "$source_filepath")
	
	# Get line containing <code id="registration_token">
	if [ "$(file_contains_string "$first_line" "$REL_FILEPATH")" == "FOUND" ]; then
		line_nr=$(get_line_nr $identification_str $source_filepath)
		line=$(get_line_by_nr $line_nr $source_filepath)
		echo $line
	fi
}

gitlab_runner_is_running() {
	# TODO: determine how to reliably determine if GitLabs server is running
	arch=$1
	echo "not_running"
}


# Download the gitlab runner package
# Available architectures: https://gitlab-runner-downloads.s3.amazonaws.com/latest/index.html
get_runner_package() {
	arch=$1
	
	# Get the hardcoded/expected checksum and verify if the file already is downloaded.
	expected_checksum=$(get_expected_md5sum_of_gitlab_runner_installer_for_architecture $arch)
	if [ $(check_md5_sum "$expected_checksum" "gitlab-runner_${arch}.deb") != "EQUAL" ]; then
		# install curl
		install_curl=$(yes | sudo apt install curl)
		
		left="https://gitlab-runner-downloads.s3.amazonaws.com/latest/deb/gitlab-runner_"
		right=".deb"
		url="$left$arch$right"
		
		curl_command=$(curl -LJO "$url")
		
		# Optional: if x86_64 curl from:
		#https://archlinux.org/packages/community/x86_64/gitlab-runner/download	
	fi
	
	# make it executable
	$(sudo chmod +x "gitlab-runner_${arch}.deb")
}


# Install GitLab runner (=not install GitLab runner as a service)
install_package() {
	arch=$1
	filename="gitlab-runner_"$arch".deb"
	echo "filename=$filename"
	#install=$(sudo dpkg -i "$filename")
	install=$(dpkg -i "$filename")
	echo "install=$install"
}
#TODO: reverse installation


# Register GitLab Runner
register_gitlab_runner() {

	# TODO: (doubt) goto: http://127.0.0.1/admin/application_settings/ci_cd#js-ci-cd-settings
	# TODO: (doubt) disable "Enable shared runners for new projects"

	# TODO: get token:
	# http://127.0.0.1/admin/runners
	# TODO: automatically get runner token from gitlab server
	
	url="http://localhost"
	description=trucolrunner
	executor=shell
	dockerimage="ruby:2.6"

	# Command to run runner in Docker (won't access the machine localhost this way/doesn't work).
	#registration=$(sudo gitlab-runner register \
	#--non-interactive \
	#--url $url \
	#--description $description \
	#--registration-token $runner_token \
	#--executor docker \
	#--docker-image ruby:2.6)
	
	# TODO: verify it works without clone-url
	register=$(sudo gitlab-runner register \
	--non-interactive \
	--url http://localhost \
	--description $description \
	--registration-token $runner_token \
	--executor $executor)
}

# Create a GitLab CI user
create_gitlab_ci_user() {
	sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
}


# Install GitLab runner service
install_gitlab_runner_service() {
	sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
}


# Start GitLab runner service
start_gitlab_runner_service() {
	sudo gitlab-runner start
}


# Run GitLab runner service
run_gitlab_runner_service() {
	#run_command=$(sudo gitlab-runner run &)
	run_command=$(sudo gitlab-runner run --user=gitlab-runner &)
	#run_command=$(nohup sudo gitlab-runner run > gitlab_runner_run.out &)
	#run_command=$(nohup sudo gitlab-runner run --user=gitlab-runner &)
	echo "service is running"
}