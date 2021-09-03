#!/bin/bash

source src/helper.sh
source src/hardcoded_variables.txt
source src/creds.txt
source src/create_personal_access_token.sh

# TODO: change 127.0.0.1 with gitlab server address variable

#source src/run_ci_job.sh && receipe
receipe() {
	$(delete_target_folder)
	$(delete_repository)
	$(create_repository)
	$(clone_repository)
	$(export_repo)
	$(commit_changes)
	$(push_changes)
}

commit_changes() {
	output=$(cd ../$SOURCE_FOLDERNAME && git add *)
	output=$(cd ../$SOURCE_FOLDERNAME && git add .gitignore)
	output=$(cd ../$SOURCE_FOLDERNAME && git add .gitlab-ci.yml)
	output=$(cd ../$SOURCE_FOLDERNAME && git commit -m "Uploaded files to trigger GitLab runner.")
}

push_changes() {
	repo_name=$(echo $SOURCE_FOLDERNAME | tr -d '\r')
	gitlab_username=$(echo $gitlab_server_account | tr -d '\r')
	gitlab_server_password=$(echo $gitlab_server_password | tr -d '\r')
	output=$(cd ../$SOURCE_FOLDERNAME && git push http://$gitlab_username:$gitlab_server_password@127.0.0.1/$gitlab_username/$repo_name.git)
	echo "outrput=$output"
}

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
	#$(delete_target_folder)
	cp -r "$SOURCE_FOLDERPATH" ../
	# create target folder
	# copy source folder to target
	
}


create_repository() {
#source src/run_ci_job.sh && create_repository
	# Create personal GitLab access token
	create_gitlab_personal_access_token
	
	# load personal_access_token
	personal_access_token=$(echo $GITLAB_PERSONAL_ACCESS_TOKEN | tr -d '\r')
	
	# Create repo named foobar
	repo_name=$SOURCE_FOLDERNAME
	output=$(curl -H "Content-Type:application/json" http://127.0.0.1/api/v4/projects?private_token=$personal_access_token -d "{ \"name\": \"$repo_name\" }")
	echo "output=$output"
}

#source src/run_ci_job.sh && delete_repository
delete_repository() {
	# load personal_access_token
	personal_access_token=$(echo $GITLAB_PERSONAL_ACCESS_TOKEN | tr -d '\r')
	
	# Create repo named foobar
	gitlab_username=$(echo $gitlab_server_account | tr -d '\r')
	repo_name=$SOURCE_FOLDERNAME
	
	output=$(curl -H 'Content-Type: application/json' -H "Private-Token: $personal_access_token" -X DELETE http://127.0.0.1/api/v4/projects/$gitlab_username%2F$repo_name)
	echo "output=$output"
}

#source src/run_ci_job.sh && clone_repository
clone_repository() {
	repo_name=$(echo $SOURCE_FOLDERNAME | tr -d '\r')
	gitlab_username=$(echo $gitlab_server_account | tr -d '\r')
	gitlab_server_password=$(echo $gitlab_server_password | tr -d '\r')
	#git@127.0.0.1:root/foobar.git
	#
	rm -r ../$repo_name
	echo "/$gitlab_server_account=$gitlab_server_account"
	echo "/$gitlab_server_password=$gitlab_server_password"
	output=$(cd .. && git clone http://$gitlab_username:$gitlab_server_password@127.0.0.1/$gitlab_username/$repo_name.git)
	echo "output=$output"
}