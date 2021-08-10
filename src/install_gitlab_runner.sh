#!/bin/bash
# Source: https://www.youtube.com/watch?v=G8ZONHOTAQk 
# Source: https://docs.gitlab.com/runner/install/
# Source: https://docs.gitlab.com/runner/install/linux-manually.html

source src/helper.sh

# Determine architecture.
# Source: https://askubuntu.com/questions/189640/how-to-find-architecture-of-my-pc-and-ubuntu
get_architecture() {
	architecture=$(uname -m)
	
	# Parse architecture to what is available for GitLab Runner
	# Source: https://stackoverflow.com/questions/65450286/how-to-install-gitlab-runner-to-centos-fedora
	if [ "$architecture"=="x86_64" ]; then
		architecture=amd64
	fi
	
	echo $architecture
}

# Download the gitlab runner package
# Available architectures: https://gitlab-runner-downloads.s3.amazonaws.com/latest/index.html
get_runner_package() {
	arch=$1
	
	# Get the hardcoded/expected checksum and verify if the file already is downloaded.
	expected_checksum=$(get_expected_md5sum_for_architecture $arch)
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



install_package() {
	arch=$1
	filename="gitlab-runner_"$arch".deb"
	echo "filename=$filename"
	install=$(sudo dpkg -i "$filename")
	echo "install=$install"
}

# Register GitLab Runner
register_gitlab_runner() {

	# TODO: goto: http://127.0.0.1/admin/application_settings/ci_cd#js-ci-cd-settings
	# TODO: disable "Enable shared runners for new projects"

	# TODO: get token:
	# http://127.0.0.1/admin/runners
	# TODO: automatically pass the gitlab server address: 127.0.0.1 (or tor address or website)
	# TODO: automatically get runner token from gitlab server
	# TODO: automatically pass runner token to GitLab register
	# TODO: automatically pass name of runner to GitLab Register
	# TODO: automatically pass tags to runner.
	# TODO: automatically add execution method, e.g. docker or shell (docker is more machine-agnostic)
	# TODO: specify default Docker image (e.g. ruby:2.6)
	registration=$(sudo gitlab-runner register)
	#url=https://127.0.0.1
	url="http://127.0.0.1"
	# TODO: get token from file in gitignore
	token=""
	description=trucolrunner
	taglist=notags
	executor=docker
	dockerimage="ruby:2.6"
	registration=$(sudo gitlab-runner register --url $url --token $token --description $description --tag-list $taglist --executor $docker --docker-image $dockerimage)
	# TODO: make command work
	registration=$(sudo gitlab-runner register --url http://127.0.0.1 --token  --description trucolrunner --tag-list notags --executor docker --docker-image ruby:2.6)
}

# gitlab-runner install (just to besure)
# sudo gitlab-runner start