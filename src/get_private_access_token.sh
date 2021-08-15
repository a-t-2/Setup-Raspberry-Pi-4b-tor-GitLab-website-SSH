#!/bin/bash
# Source: https://github.com/MxNxPx/gitlab-cicd-demo/blob/aee86e45f5bc603a5055f0cd391cd6b184f1d6c3/get-runner-reg.sh
source src/hardcoded_variables.txt
source src/creds.txt



get_gitlab_server_private_access_token() {
	GITURL=$GITLAB_SERVER_HTTP_URL
	GITUSER=$gitlab_server_account
	GITROOTPWD=$gitlab_server_password
	
	# 1. curl for the login page to get a session cookie and the sources with the auth tokens
	body_header=$(curl -k -c gitlab-cookies.txt -i "${GITURL}/users/sign_in" -sS)
	
	# grep the auth token for the user login for
	#   not sure whether another token on the page will work, too - there are 3 of them
	csrf_token=$(echo $body_header | perl -ne 'print "$1\n" if /new_user.*?authenticity_token"[[:blank:]]value="(.+?)"/' | sed -n 1p)
	
	# 2. send login credentials with curl, using cookies and token from previous request
	curl -sS -k -b gitlab-cookies.txt -c gitlab-cookies.txt "${GITURL}/users/sign_in" \
		--data "user[login]=${GITUSER}&user[password]=${GITROOTPWD}" \
		--data-urlencode "authenticity_token=${csrf_token}"  -o /dev/null
	
	# 3. send curl GET request to gitlab runners page to get registration token
	body_header=$(curl -sS -k -H 'user-agent: curl' -b gitlab-cookies.txt "${GITURL}/admin/runners" -o gitlab-header.txt)
	reg_token=$(cat gitlab-header.txt | perl -ne 'print "$1\n" if /code id="registration_token">(.+?)</' | sed -n 1p)
	echo $reg_token
}