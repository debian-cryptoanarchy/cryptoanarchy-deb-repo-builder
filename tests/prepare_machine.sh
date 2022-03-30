#!/bin/bash

set -e

test_dir="`dirname "$0"`"
pkg_dir="$1"

. "$test_dir/common.sh"

test -n "$DPKG_DEBUG_LEVEL" && echo "debug $DPKG_DEBUG_LEVEL" | sudo tee /etc/dpkg/dpkg.cfg.d/cadr-test >/dev/null

# If we don't care to run a new VM for each upgrade, we can reuse the repo
if [ -e "$apt_repo_dir.tmp" ];
then
	sudo mv "$apt_repo_dir.tmp" "$apt_repo_dir"
	# Give some time for apt-local-repository to see the changes
	sleep 5
	sudo apt-get update
else
	sudo mkdir -p "$apt_repo_dir"
	sudo cp "$pkg_dir"/*.deb "$apt_repo_dir"
	sudo cp "$test_data_dir"/microsoft_apt.list /etc/apt/sources.list.d/microsoft.list
	sudo apt-key add < "$test_data_dir"/microsoft_key.gpg
	sudo apt-get update
	sudo apt-get install -y local-apt-repository
	sudo apt-get update
	"$test_dir/set_local_cert_config.sh"
fi
