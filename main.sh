#while getopts u:a:f: flag
#do
#    case "${flag}" in
#        u) username=${OPTARG};;
#        a) age=${OPTARG};;
#        f) fullname=${OPTARG};;
#    esac
#done
#echo "Username: $username";
#echo "Age: $age";
#echo "Full Name: $fullname";

source src/install_and_run_gitlab_runner.sh
$(install_gitlab_runner amd64)