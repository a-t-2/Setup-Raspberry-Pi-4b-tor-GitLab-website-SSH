#!/bin/bash

source src/helper.sh
source src/hardcoded_variables.txt

# source src/run_ci_job.sh && export_repo
# Write function that exportis the test-repository to a separate external folder.
delete_target_folder() {
	# check if target folder already exists
	# delete target folder if it already exists
	if [ -d "../$SOURCE_FOLDERNAME" ] ; then
	    rm -r "../$SOURCE_FOLDERNAME"
	fi
	# create target folder
	# copy source folder to target
	
}

export_repo() {
	# check if target folder already exists
	
	# delete target folder if it already exists
	$(delete_target_folder)
	cp -r "$SOURCE_FOLDERPATH" ../
	# create target folder
	# copy source folder to target
	
}
# Write function that removes test repository at GitLab account.
# Write function that passes ssh credentials to root user.
# Write function that adds the repository to the GitLab account.

create_repository() {
	# Create personal GitLab access token
	create_gitlab_personal_access_token
	
	# Create repo named foo

	curl -H "Content-Type:application/json" https://gitlab.com/api/v4/projects?private_token=foo -d "{ \"name\": \"$1\" }"

}