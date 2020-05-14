#!/bin/bash

check() {
	package="$1"
	package_type="$2"
	action="$3"
	if [ -n "$package_type" ];
	then
		if "$common_script_dir/$package_type/$action.sh" "$package";
		then
			return 0
		else
			return 1
		fi
	fi
}

sudo() {
	/usr/bin/sudo -E "$@"
}

set -e

test_data_dir="`dirname "$0"`/data"
apt_repo_dir="/srv/local-apt-repository"
pkg_dir="$1"
common_script_dir="`dirname "$0"`/common"
packages="bitcoind bitcoin-mainnet bitcoin-pruned-mainnet bitcoin-fullchain-mainnet bitcoin-txindex-mainnet bitcoin-zmq-mainnet bitcoin-rpc-proxy bitcoin-rpc-proxy-mainnet bitcoin-timechain-mainnet electrs electrs-mainnet btcpayserver btcpayserver-system-mainnet btcpayserver-system-selfhost-mainnet lnd lnd-system-mainnet ridetheln ridetheln-system ridetheln-system-selfhost ridetheln-lnd-system-mainnet selfhost selfhost-nginx selfhost-onion selfhost-clearnet selfhost-clearnet-certbot tor-hs-patch-config"
service_packages="bitcoin-mainnet bitcoin-rpc-proxy-mainnet electrs-mainnet nbxplorer-mainnet btcpayserver-system-mainnet lnd-mainnet ridetheln-mainnet"
# pruned, txindex and fullchain conflict, so we only install txindex
non_conflict_packages="`echo $packages | tr ' ' '\n' | grep -v bitcoin-fullchain | grep -v bitcoin-pruned`"

declare -A remove_depends

# APT screws up in certain scenarios when removing packages by not removing
# depending packages. So we fix it manually by removing them explicitly.
remove_depends["bitcoin-pruned-mainnet"]="bitcoin-mainnet"
remove_depends["bitcoin-fullchain-mainnet"]="bitcoin-mainnet"
remove_depends["bitcoin-txindex-mainnet"]="bitcoin-mainnet"
remove_depends["bitcoin-zmq-mainnet"]="bitcoin-mainnet"
remove_depends["selfhost-onion"]="selfhost"
remove_depends["selfhost-clearnet"]="selfhost"
remove_depends["selfhost-clearnet-certbot"]="selfhost-clearnet selfhost"
remove_depends["tor-hs-patch-config"]="selfhost-onion selfhost"

declare -A package_type

for package in $service_packages;
do
	package_type["$package"]="service"
done

export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical

sudo mkdir -p "$apt_repo_dir"
sudo cp "$1"/*.deb "$apt_repo_dir"
sudo cp "$test_data_dir"/microsoft_apt.list /etc/apt/sources.list.d/microsoft.list
sudo apt-key add < "$test_data_dir"/microsoft_key.gpg
sudo apt update
sudo apt install -y local-apt-repository
sudo apt update
sudo mkdir -p /etc/selfhost
sudo cp "$test_data_dir/clearnet-certbot.test.conf"  /etc/selfhost

for package in $packages;
do
	package_type="${package_type["$package"]}"

	# selfhost-clearnet-related options are needed several times, so we needed
	# to init them at the beginning of each run due to purge being at the end.
	sudo debconf-set-selections < "$test_data_dir/configuration"
	# Detect Qubes and redirect paths with big files to /rw
	if [ -d /rw -a -e /etc/qubes ];
	then
		sudo debconf-set-selections < "$test_data_dir/qubes-configuration"
	fi
	sudo debconf-set-selections < "$test_data_dir/configuration"
	echo "Installing package $package" >&2
	sudo apt install -y "$package"
	echo "Checking package $package" >&2
	check "$package" "$package_type" "after_install"
	echo "Reinstalling package $package" >&2
	sudo apt reinstall -y "$package"
	echo "Checking package $package" >&2
	check "$package" "$package_type" "after_install"
	echo "Removing package $package" >&2
	sudo apt remove -y "$package" ${remove_depends["$package"]}
	echo "Checking package $package" >&2
	check "$package" "$package_type" "after_remove"
	echo "Purging package $package" >&2
	sudo apt purge -y "$package" ${remove_depends["$package"]}
	# We need to remove content of home dir, but not the dir itself
	sudo rm -rf "/var/lib/$package"/*
	# Disable connections after bitcoin-mainnet was tested
	# in order to avoid fetching blocks during testing.
	if [ "$package" = "bitcoin-mainnet" ];
	then
		# The directory is removed after purge, so we recreate it
		# Next purges will complain but work anyway.
		sudo mkdir -p /etc/bitcoin-mainnet/conf.d
		echo 'noconect=1' | sudo tee /etc/bitcoin-mainnet/conf.d/noconnect >/dev/null
	fi
done

echo "Basic test done, preparing upgrade test" >&2
# TODO, this would be better with previous configuration, maybe on a clean OS instead
sudo mv "$apt_repo_dir" "$apt_repo_dir.tmp"
sudo cp "$test_data_dir/experimental_apt.list" /etc/apt/sources.list.d/cryptoanarchy-experimental.list
sudo apt-key add < "$test_data_dir/experimental_key.gpg"
sudo apt update
sudo apt install -y $non_conflict_packages
sudo mv "$apt_repo_dir.tmp" "$apt_repo_dir"
# Give some time for apt-local-repository to see the changes
sleep 5
sudo apt update

for package in $non_conflict_packages;
do
	package_type="${package_type["$package"]}"

	echo "Upgrading package $package" >&2
	sudo apt install -y "$package"
	echo "Checking package $package" >&2
	check "$package" "$package_type" "after_upgrade"
done
