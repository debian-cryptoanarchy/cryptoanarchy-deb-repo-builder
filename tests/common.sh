. "$test_dir/common_vars.sh"

apt_repo_dir="/srv/local-apt-repository"
common_script_dir="$test_dir/common"

# Performs package-specific checks
check() {
	package="$1"
	package_type="$2"
	action="$3"
	per_package_dir="$test_dir/per-package/$package"
	if [ -e "$per_package_dir/alone/$action.sh" ];
	then
		"$per_package_dir/alone/$action.sh" || return 1
	fi
	dpkg --get-selections | awk '{ print $1 }' | while read dep;
	do
		if [ -e "$test_dir/per-package/$dep/$action.sh" ];
		then
			"$test_dir/per-package/$dep/$action.sh" || return 1
		fi
	done
	if [ -n "$package_type" ];
	then
		"$common_script_dir/$package_type/$action.sh" "$package" || return 1
	fi
}

# Pass env to sudo by default
sudo() {
	/usr/bin/sudo -E "$@"
}

preload_config() {
	# Detect Qubes and redirect paths with big files to /rw
	if [ -d /rw -a -e /etc/qubes ];
	then
		sudo debconf-set-selections < "$test_data_dir/qubes-configuration" || return 1
	fi
	sudo debconf-set-selections < "$test_data_dir/configuration" || return 1
}

service_packages="bitcoin-mainnet bitcoin-regtest bitcoin-rpc-proxy-mainnet electrs-mainnet electrs-regtest nbxplorer-mainnet btcpayserver-system-mainnet btcpayserver-system-regtest lnd-system-mainnet lnd-system-regtest ridetheln-system thunderhub-system-mainnet thunderhub-system-regtest btc-rpc-explorer-mainnet btc-rpc-explorer-regtest"

declare -A remove_depends

# APT screws up in certain scenarios when removing packages by not removing
# depending packages. So we fix it manually by removing them explicitly.
remove_depends["bitcoin-pruned-mainnet"]="bitcoin-mainnet"
remove_depends["bitcoin-fullchain-mainnet"]="bitcoin-mainnet"
remove_depends["bitcoin-txindex-mainnet"]="bitcoin-mainnet"
remove_depends["bitcoin-zmq-mainnet"]="bitcoin-mainnet"
remove_depends["bitcoin-pruned-regtest"]="bitcoin-regtest"
remove_depends["bitcoin-fullchain-regtest"]="bitcoin-regtest"
remove_depends["bitcoin-txindex-regtest"]="bitcoin-regtest"
remove_depends["bitcoin-zmq-regtest"]="bitcoin-regtest"
remove_depends["selfhost-onion"]="selfhost"
remove_depends["selfhost-clearnet"]="selfhost"
remove_depends["selfhost-clearnet-certbot"]="selfhost-clearnet selfhost"
remove_depends["tor-hs-patch-config"]="selfhost-onion selfhost"

declare -A package_type

for _package in $service_packages;
do
	package_type["$_package"]="service"
done

# Avoid forgetting to set these
export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical
