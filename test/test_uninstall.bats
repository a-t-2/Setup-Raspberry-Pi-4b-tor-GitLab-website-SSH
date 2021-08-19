#!./test/libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'
load 'libs/bats-file/load'



source uninstall.sh


@test "If error is thrown for arguments -s and -y." {
	run bash -c "./uninstall.sh -s -y"
	assert_failure
	assert_output --partial "ERROR, you chose to manually override the prompt for the soft uninstallation, but the soft uninstallation does not not prompt for confirmation."
	assert_output "ERROR, you chose to manually override the prompt for the soft uninstallation, but the soft uninstallation does not not prompt for confirmation."
}
