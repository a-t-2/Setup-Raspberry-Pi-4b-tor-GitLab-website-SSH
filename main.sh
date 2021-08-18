while getopts u:pat:pw:a:f: flag
do
    case "${flag}" in
        u) username=${OPTARG};;
        pat) gitlab_server_personal_access_token=${OPTARG};;
        pw) gitlab_server_root_pwd=${OPTARG};;
        a) age=${OPTARG};;
        f) fullname=${OPTARG};;
    esac
done
echo "Username: $username";
echo "GitLab server personal access token: $gitlab_server_personal_access_token";
echo "GitLab server root pwd: $gitlab_server_root_pwd";
echo "Age: $age";
echo "Full Name: $fullname";


source src/install_and_boot_gitlab_server.sh
source src/install_and_boot_gitlab_runner.sh
source src/hardcoded_variables.txt

# arguments:
# TODO: check if the GitLab server is already running.
#install_and_run_gitlab_server
install_and_run_gitlab_runner


#source src/install_and_run_gitlab_runner.sh
#$(install_gitlab_runner amd64)

# TODO: 
# call the script that installs tor and ssh for the username
# ensure the docker id is gotten correctly.
# set the gitlab root password at the creation of the GitLab server
# call the gitlab runner installation
# Create a cronjob that starts the tor ssh service at startup
# TODO: remove the infintely growing list of responses in the tor_ssh script
# TODO; get a quick test to check if the gitlab server is up.
# TODO: get a quick test to check if the gitlab runner is up.
# TODO: reboot the device if the Gitlab server is down.
# TODO: reboot the device if the Gitlab runner is down.
