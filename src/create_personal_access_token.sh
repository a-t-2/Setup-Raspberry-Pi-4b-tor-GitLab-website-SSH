#!/bin/bash
# Source: https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html#programmatically-creating-a-personal-access-token
source src/hardcoded_variables.txt
source src/creds.txt
source src/helper.sh

gitlab_host=$GITLAB_SERVER_HTTP_URL
gitlab_user=$gitlab_server_account
gitlab_password=$gitlab_server_password


# Get shared registration token:
#source: https://github.com/veertuinc/getting-started/blob/ef159275743b2481e68feb92b2c56b5698ad6d6c/GITLAB/install-and-run-anka-gitlab-runners-on-mac.bash
#export SHARED_REGISTRATION_TOKEN="$(sudo docker exec -i 5303124d7b87 bash -c "gitlab-rails runner -e production \"puts Gitlab::CurrentSettings.current_application_settings.runners_registration_token\"")"
#9r6sPoAx3BFqZnxfexLS


# source src/create_personal_access_token.sh && create_gitlab_personal_access_token
# verify at: http://127.0.0.1/-/profile/personal_access_tokens
create_gitlab_personal_access_token() {
	docker_container_id=$(get_docker_container_id_of_gitlab_server)
	echo "docker_container_id=$docker_container_id"
	# trim newlines
	personal_access_token=$(echo $GITLAB_PERSONAL_ACCESS_TOKEN | tr -d '\r')
	gitlab_username=$(echo $gitlab_server_account | tr -d '\r')
	token_name=$(echo $GITLAB_PERSONAL_ACCESS_TOKEN_NAME | tr -d '\r')
	
	# Source: https://gitlab.example.com/-/profile/personal_access_tokens?name=Example+Access+token&scopes=api,read_user,read_registry
	
	# Create a personal access token
	# TODO: replace hardcoded docker container id with the id extracted from `sudo docker ps -a` command.
	
	#output="$(sudo docker exec -i 5303124d7b87 bash -c "gitlab-rails runner \"token = User.find_by_username('root').personal_access_tokens.create(scopes: [:read_user, :read_repository], name: 'Automation token'); token.set_token('token-string-here123'); token.save! \"")"
	
	# WORKS
	#output="$(sudo docker exec -i 17bdda47be16 bash -c "gitlab-rails runner \"token = User.find_by_username('root').personal_access_tokens.create(scopes: [:read_user, :read_repository], name: 'Automation token'); token.set_token('token-string-here124'); token.save! \"")"
	
	#WORKS
	output="$(sudo docker exec -i 17bdda47be16 bash -c "gitlab-rails runner \"token = User.find_by_username('root').personal_access_tokens.create(scopes: [:read_user, :read_repository], name: 'Automationtoken0'); token.set_token('token-string-here123'); token.save! \"")"
	
	# undefined local variable or method `root' for main:Object
	output="$(sudo docker exec -i 17bdda47be16 bash -c "gitlab-rails runner \"token = User.find_by_username($gitlab_username).personal_access_tokens.create(scopes: [:read_user, :read_repository], name: 'Automationtoken1'); token.set_token('token-string-here123'); token.save! \"")"
	
	#undefined method `personal_access_tokens' for nil:NilClass
	output="$(sudo docker exec -i 17bdda47be16 bash -c "gitlab-rails runner \"token = User.find_by_username('$gitlab_username').personal_access_tokens.create(scopes: [:read_user, :read_repository], name: 'Automationtoken2'); token.set_token('token-string-here123'); token.save! \"")"
	
	# much error
	output="$(sudo docker exec -i 17bdda47be16 bash -c "gitlab-rails runner \"token = User.find_by_username(\'$gitlab_username\').personal_access_tokens.create(scopes: [:read_user, :read_repository], name: 'Automationtoken3'); token.set_token('token-string-here123'); token.save! \"")"
	
	# says \' is not expected
	output="$(sudo docker exec -i 17bdda47be16 bash -c "gitlab-rails runner \"token = User.find_by_username(\\'$gitlab_username\\').personal_access_tokens.create(scopes: [:read_user, :read_repository], name: 'Automationtoken4'); token.set_token('token-string-here123'); token.save! \"")"
	
	# undefined local variable or method `root' for main:Object
	output="$(sudo docker exec -i 17bdda47be16 bash -c "gitlab-rails runner \"token = User.find_by_username(\"$gitlab_username\").personal_access_tokens.create(scopes: [:read_user, :read_repository], name: 'Automationtoken5'); token.set_token('token-string-here123'); token.save! \"")"

	output="$(sudo docker exec -i 17bdda47be16 bash -c "gitlab-rails runner \"token = User.find_by_username("$gitlab_username").personal_access_tokens.create(scopes: [:read_user, :read_repository], name: 'Automationtoken6'); token.set_token('token-string-here123'); token.save! \"")"
	
	# undefined method `personal_access_tokens' for nil:NilClass
	output="$(sudo docker exec -i 17bdda47be16 bash -c "gitlab-rails runner \"token = User.find_by_username(/"$gitlab_username/").personal_access_tokens.create(scopes: [:read_user, :read_repository], name: 'Automationtoken7'); token.set_token('token-string-here123'); token.save! \"")"
	
	# wrong nr of arguments given at personal access
	output="$(sudo docker exec -i 17bdda47be16 bash -c "gitlab-rails runner \"token = User.find_by_username("'"$gitlab_username"'").personal_access_tokens.create(scopes: [:read_user, :read_repository], name: 'Automationtoken8'); token.set_token('token-string-here123'); token.save! \"")"
	
	# undefined method `personal_access_tokens' for nil:NilClass
	output="$(sudo docker exec -i 17bdda47be16 bash -c "gitlab-rails runner \"token = User.find_by_username(\"'\"$gitlab_username\"'\").personal_access_tokens.create(scopes: [:read_user, :read_repository], name: 'Automationtoken9'); token.set_token('token-string-here123'); token.save! \"")"
	
	# TODO: verify both fail
	output="$(sudo docker exec -i 17bdda47be16 bash -c "gitlab-rails runner \"token = User.find_by_username("'\$gitlab_username'").personal_access_tokens.create(scopes: [:read_user, :read_repository], name: 'Automationtoken10'); token.set_token('token-string-here123'); token.save! \"")"
	
	# TODO: verify both fail
	output="$(sudo docker exec -i 17bdda47be16 bash -c "gitlab-rails runner \"token = User.find_by_username('\$gitlab_username').personal_access_tokens.create(scopes: [:read_user, :read_repository], name: 'Automationtoken11'); token.set_token('token-string-here123'); token.save! \"")"
	
	# Target
	# sudo docker exec -i 17bdda47be16 bash -c "gitlab-rails runner \"token = User.find_by_username('root').personal_access_tokens.create(scopes: [:read_user, :read_repository], name: 'Automation token'); token.set_token('token-string-here124'); token.save! \""
	
	#some_string='sudo docker exec -i '$docker_container_id' bash -c "gitlab-rails runner \"token = User.find_by_username('"'"$gitlab_username"'"').personal_access_tokens.create(scopes: [:read_user, :read_repository], name: '"'"$token_name"'"'); token.set_token('"'"$personal_access_token"'"'); token.save! \""'
	
	#some_string="text$gitlab_username""Somemoretext"
	#echo "some_string=$some_string"
	#echo $some_string > temp.txt
	
	
	#undefined method `personal_access_tokens' for nil:NilClass
	#output="$(sudo docker exec -i $docker_container_id bash -c "gitlab-rails runner \"token = User.find_by_username('$gitlab_username').personal_access_tokens.create(scopes: [:read_user, :read_repository], name: '$token_name'); token.set_token('$personal_access_token'); token.save! \"")"
	
	# undefined local variable or method `root' for main:Objec
	#output="$(sudo docker exec -i $docker_container_id bash -c "gitlab-rails runner \"token = User.find_by_username("$gitlab_username").personal_access_tokens.create(scopes: [:read_user, :read_repository], name: "$token_name"); token.set_token("$personal_access_token"); token.save! \"")"
	
	
	#	Please specify a valid ruby command or the path of a script to run.
	#Run 'rails runner -h' for help.
	#
	#/opt/gitlab/embedded/lib/ruby/gems/2.7.0/gems/railties-6.0.3.6/lib/rails/commands/runner/runner_command.rb:45: syntax error, unexpected backslash, expecting ')'
	#token = User.find_by_username(\'roo...
	#                              ^
	#/opt/gitlab/embedded/lib/ruby/gems/2.7.0/gems/railties-6.0.3.6/lib/rails/commands/runner/runner_command.rb:45: syntax error, unexpected backslash, expecting end-of-input
	#...itory], name: \'sometokenname'\); token.set_token(\'somelong...
	#...                              ^
	##output="$(sudo docker exec -i $docker_container_id bash -c "gitlab-rails runner \"token = User.find_by_username(\'$gitlab_username\').personal_access_tokens.create(scopes: [:read_user, :read_repository], name: \'$token_name'\); token.set_token(\'$personal_access_token'\); token.save! \"")"
	
	
	#/opt/gitlab/embedded/lib/ruby/gems/2.7.0/gems/railties-6.0.3.6/lib/rails/commands/runner/runner_command.rb:45: warning: encountered \r in middle of line, treated as a mere space
	#Please specify a valid ruby command or the path of a script to run.
	#Run 'rails runner -h' for help.
	#
	#/opt/gitlab/embedded/lib/ruby/gems/2.7.0/gems/railties-6.0.3.6/lib/rails/commands/runner/runner_command.rb:45: syntax error, unexpected backslash
	#...ser, :read_repository], name: \'sometokenname'\); token.set_...
	#...                              ^
	#/opt/gitlab/embedded/lib/ruby/gems/2.7.0/gems/railties-6.0.3.6/lib/rails/commands/runner/runner_command.rb:45: syntax error, unexpected backslash, expecting end-of-input
	#...itory], name: \'sometokenname'\); token.set_token(\'somelong...
	#...                              ^
	##output="$(sudo docker exec -i $docker_container_id bash -c "gitlab-rails runner \"token = User.find_by_username($gitlab_username).personal_access_tokens.create(scopes: [:read_user, :read_repository], name: \'$token_name'\); token.set_token(\'$personal_access_token'\); token.save! \"")"
	
	#Objective:
	#sudo gitlab-rails runner "token = User.find_by_username('automation-bot').personal_access_tokens.create(scopes: [:read_user, :read_repository], name: 'Automation token'); token.set_token('token-string-here123'); token.save!"
	# embedded objective:
	#sudo docker exec -i 5303124d7b87 bash -c "gitlab-rails runner \"token = User.find_by_username('root').personal_access_tokens.create(scopes: [:read_user, :read_repository], name: 'Automation token'); token.set_token('token-string-here123'); token.save! \""
	
	p1="sudo docker exec -i $docker_container_id bash -c "
	p2='"'
	p3="gitlab-rails runner \"token = User.find_by_username("
	p4="'"
	#p4="\'"
	#p4="\\'"
	#$gitlab_username
	p6="'"
	#p6="\'"
	#p6="\\'"
	p7=").personal_access_tokens.create(scopes: [:read_user, :read_repository], name: "
	p8="'"
	#$token_name
	p10="'"
	p11="); token.set_token("
	p12="'"
	#$personal_access_token
	p14="'"
	p15="); token.save! "
	p16='\"'
	p17='"'
	command="$p1$p2$p3$p4$gitlab_username$p6$p7$p8$token_name$p10$p11$p12$personal_access_token$p14$p15$p16$p17"
	#command="$p1$p2$p3$p4'$gitlab_username$p6 words"
	#command="$p1$p2$p3'$gitlab_username'words"
	#command="$p1$p2$p3$gitlab_username asdfasdf words"
	#$p6$p7$p8$token_name$p10$p11$p12$personal_access_token$p14$p15$p16$p17"
	
	
	#command="sudo docker exec -i $docker_container_id bash -c \"gitlab-rails runner \"token = User.find_by_username(\'"$gitlab_username"\').personal_access_tokens.create(scopes: [:read_user, :read_repository], name: \'"$token_name"\'); token.set_token(\'"$personal_access_token"\'); token.save! \""
	#echo "command=$command"
	#$($command)
	#read -p "command=$command"
	#read -p "$p1$p2$p3$p4$gitlab_username$p6$p7$p8$token_name$p10$p11$p12$personal_access_token$p14$p15$p16$p17"
	
	#output="$(sudo docker exec -i $docker_container_id bash -c "gitlab-rails runner \"token = User.find_by_username($gitlab_username).personal_access_tokens.create(scopes: [:read_user, :read_repository], name: $token_name); token.set_token($personal_access_token); token.save! \"")"
	echo "output=$output"
	
}

