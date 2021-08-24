#!/bin/bash
# Source: https://www.youtube.com/watch?v=G8ZONHOTAQk 
# Source: https://docs.gitlab.com/runner/install/
# Source: https://docs.gitlab.com/runner/install/linux-manually.html

source src/helper.sh
source src/hardcoded_variables.txt
source src/get_gitlab_server_runner_token.sh

# TODO: change to install and boot
install_and_run_gitlab_runner() {
	arch=get_architecture
	# TODO: verify if architecture is supported, raise error if not
	# TODO: Mention that support for the architecture can be gained by
	# downloading the right GitLab Runner installation package and adding
	# its verified md5sum into hardcoded_variables.txt (possibly adding an if statement 
	# to get_architecture().)
	
	if [ $(gitlab_runner_is_running $arch) == "NOTRUNNING" ]; then
		get_runner_package $arch
		install_package $arch
		register_gitlab_runner
		create_gitlab_ci_user
		install_gitlab_runner_service
		start_gitlab_runner_service
		run_gitlab_runner_service
	fi
	echo "COMPLETED RUNNER INSTALLATION."
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
	# Source: https://forum.gitlab.com/t/access-token-with-curl-is-redirecting-to-log-in-page-was-working-previously/21309
	#https://gitlab.com/gitlab-org/gitlab-foss/-/issues/12458
	# https://stackoverflow.com/questions/31805041/how-to-access-gitlab-issues-using-curl
	# https://gist.github.com/michaellihs/5ef5e8dbf48e63e2172a573f7b32c638
	curl -vk --header "PRIVATE-TOKEN: MY.TOKEN.HERE" https://gitlab.SOMEWHERE.com/api/v3
	curl -vk --header "PRIVATE-TOKEN: 9r6sPoAx3BFqZnxfexLS" http://127.0.0.1/admin/runners
	curl -vk --header "PRIVATE-TOKEN: token-string-here123" http://127.0.0.1/admin/runners
	
	# TODO: call function to get line
	
	
	# TODO: call function to get code
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
	runner_token=$(get_gitlab_server_runner_tokenV1)
	echo "runner_token=$runner_token"

	# Command to run runner in Docker (won't access the machine localhost this way/doesn't work).
	#registration=$(sudo gitlab-runner register \
	#--non-interactive \
	#--url $url \
	#--description $description \
	#--registration-token $runner_token \
	#--executor docker \
	#--docker-image ruby:2.6)
	
	#read -p "runner_token=$runner_token" >&2
	
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
	gitlab_runner_username=gitlab-runner
	$(sudo $gitlab_runner_username install --user=$gitlab_runner_username --working-directory=/home/$gitlab_runner_username)
	$(sudo usermod -a -G sudo $gitlab_runner_username)
	$(sudo rm /home/$gitlab_runner_username/.*)
	
	visudo_line="$gitlab_runner_username ALL=(ALL) NOPASSWD: ALL"
	filepath="/etc/sudoers"
	added_runner_to_visudo=$(visudo_contains "$visudo_line" "$filepath")
	if [  "$added_runner_to_visudo" == "NOTFOUND" ]; then
		echo "$gitlab_runner_username ALL=(ALL) NOPASSWD: ALL" | sudo EDITOR='tee -a' visudo
		added_runner_to_visudo=$(visudo_contains "$visudo_line" "$filepath")
		if [  "$added_runner_to_visudo" == "NOTFOUND" ]; then
			# TODO: raise exception
			echo "ERROR"
		fi
	fi
}


# Start GitLab runner service
start_gitlab_runner_service() {
	sudo gitlab-runner start
}


# Run GitLab runner service
run_gitlab_runner_service() {
	#run_command=$(sudo gitlab-runner run &)
	#run_command=$(sudo gitlab-runner run --user=gitlab-runner &)
	#run_command=$(sudo gitlab-runner run --user=gitlab-runner)
	( run_command="$(sudo gitlab-runner run)" ) &
	#( run_command="$(gitlab-runner run)" ) &
	#run_command=$(nohup sudo gitlab-runner run > gitlab_runner_run.out &)
	#run_command=$(nohup sudo gitlab-runner run --user=gitlab-runner &)
	echo "service is running"
}

#https://stackoverflow.com/questions/64257998/gitlab-ci-pipeline-fails-to-run
# TODO: automate:
#sudo visudo
#gitlab-runner ALL=(ALL) NOPASSWD: ALL
# TODO: share script that fixes it.