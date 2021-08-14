#!/bin/bash
# Source: https://www.youtube.com/watch?v=G8ZONHOTAQk 
# Source: https://docs.gitlab.com/runner/install/
# Source: https://docs.gitlab.com/runner/install/linux-manually.html

source src/helper.sh
source src/install_and_run_gitlab_runner.sh
source src/gitlab_runner_token.txt

install_gitlab_runner() {
	arch=$1
	# TODO: verify if architecture is supported, raise error if not
	# TODO: Mention that support for the architecture can be gained by
	# downloading the right GitLab Runner installation package and adding
	# its verified md5sum into hardcoded.txt (possibly adding an if statement 
	# to get_architecture().)
	
	$(get_runner_package $arch)
	$(uninstall_package $arch)
	$(deregister_gitlab_runner)
	$(remove_gitlab_ci_user)
	$(uninstall_gitlab_runner_service)
	$(stop_gitlab_runner_service)
	$(stop_running_gitlab_runner_service)
}


# Install GitLab runner (=not install GitLab runner as a service)
# TODO: uninstall package
# TODO: determine why the list of runners is not cleared/removed after uninstalling.
uninstall_package() {
	arch=$1
	filename="gitlab-runner_"$arch".deb"
	echo "filename=$filename"
	#install=$(sudo dpkg -i "$filename")
	install=$(dpkg -i "$filename")
	echo "install=$install"
}



# Register GitLab Runner
deregister_gitlab_runner() {
	
	url="http://localhost"
	description=trucolrunner
	executor=shell
	dockerimage="ruby:2.6"
	
	register=$(sudo gitlab-runner unregister --all-runners)
}

# Create a GitLab CI user
# TODO
remove_gitlab_ci_user() {
	sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
}


# Install GitLab runner service
# TODO: specify which service
uninstall_gitlab_runner_service() {
	sudo gitlab-runner uninstall
}


# Start GitLab runner service
# TODO: specify which service
stop_gitlab_runner_service() {
	sudo gitlab-runner stop
}


# Run GitLab runner service
# TODO: determine why there is no equivalent of stopping running the runner.
run_gitlab_runner_service() {
	#run_command=$(sudo gitlab-runner run &)
	run_command=$(sudo gitlab-runner verify --delete)
	#run_command=$(nohup sudo gitlab-runner run > gitlab_runner_run.out &)
	#run_command=$(nohup sudo gitlab-runner run --user=gitlab-runner &)
	echo "service is running"
}

# Troubleshooting: when runners are not removed:
# Source: https://stackoverflow.com/questions/66616014/how-do-i-delete-unregister-a-gitlab-runner
# Source: https://gitlab.com/gitlab-org/gitlab-foss/-/issues/19828#note_54956232
