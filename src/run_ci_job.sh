#!/bin/bash

source src/helper.sh
source src/hardcoded_variables.txt
source src/creds.txt
source src/create_personal_access_token.sh

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

#source src/run_ci_job.sh && create_repository
create_repository() {
	# Create personal GitLab access token
	#create_gitlab_personal_access_token
	
	# load personal_access_token
	personal_access_token=$(echo $GITLAB_PERSONAL_ACCESS_TOKEN | tr -d '\r')
	
	# Create repo named foobar
	repo_name=foobar
	output=$(curl -H "Content-Type:application/json" http://127.0.0.1/api/v4/projects?private_token=$personal_access_token -d "{ \"name\": \"$repo_name\" }")
	echo "output=$output"
}

#source src/run_ci_job.sh && delete_repository
delete_repository() {
	# load personal_access_token
	personal_access_token=$(echo $GITLAB_PERSONAL_ACCESS_TOKEN | tr -d '\r')
	
	# Create repo named foobar
	gitlab_username="root"
	repo_name="foobar"
	
	output=$(curl -H 'Content-Type: application/json' -H "Private-Token: $personal_access_token" -X DELETE http://127.0.0.1/api/v4/projects/$gitlab_username%2F$repo_name)
	echo "output=$output"
}