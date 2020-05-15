#!/bin/bash

set -e

test_dir="`dirname "$0"`"
pkg_dir="$1"

. "$test_dir/common.sh"

# If we don't care to run a new VM for each upgrade, we can reuse the repo
if [ -e "$apt_repo_dir.tmp" ];
then
	sudo mv "$apt_repo_dir.tmp" "$apt_repo_dir"
	# Give some time for apt-local-repository to see the changes
	sleep 5
	sudo apt update
else
	sudo mkdir -p "$apt_repo_dir"
	sudo cp "$pkg_dir"/*.deb "$apt_repo_dir"
	sudo cp "$test_data_dir"/microsoft_apt.list /etc/apt/sources.list.d/microsoft.list
	sudo apt-key add < "$test_data_dir"/microsoft_key.gpg
	sudo apt update
	sudo apt install -y local-apt-repository
	sudo apt update
	sudo mkdir -p /etc/selfhost
	sudo cp "$test_data_dir/clearnet-certbot.test.conf"  /etc/selfhost
fi
