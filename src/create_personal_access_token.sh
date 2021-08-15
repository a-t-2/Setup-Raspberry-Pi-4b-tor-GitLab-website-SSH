#!/bin/bash
# Source: https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html#programmatically-creating-a-personal-access-token
source src/hardcoded_variables.txt
source src/creds.txt

gitlab_host=$GITLAB_SERVER_HTTP_URL
gitlab_user=$gitlab_server_account
gitlab_password=$gitlab_server_password


# Get shared registration token:
#source: https://github.com/veertuinc/getting-started/blob/ef159275743b2481e68feb92b2c56b5698ad6d6c/GITLAB/install-and-run-anka-gitlab-runners-on-mac.bash
#export SHARED_REGISTRATION_TOKEN="$(sudo docker exec -i 5303124d7b87 bash -c "gitlab-rails runner -e production \"puts Gitlab::CurrentSettings.current_application_settings.runners_registration_token\"")"
#9r6sPoAx3BFqZnxfexLS


# Create a personal access token
# TODO: replace hardcoded docker container id with the id extracted from `sudo docker ps -a` command.
export personal_access_token="$(sudo docker exec -i 5303124d7b87 bash -c "gitlab-rails runner \"token = User.find_by_username('root').personal_access_tokens.create(scopes: [:read_user, :read_repository], name: 'Automation token'); token.set_token('token-string-here123'); token.save! \"")"
# Source: https://gitlab.example.com/-/profile/personal_access_tokens?name=Example+Access+token&scopes=api,read_user,read_registry