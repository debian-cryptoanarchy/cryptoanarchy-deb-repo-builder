test_data_dir="$test_dir/data"
apt_repo_dir="/srv/local-apt-repository"
common_script_dir="$test_dir/common"

# Performs package-specific checks
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

# Pass env to sudo by default
sudo() {
	/usr/bin/sudo -E "$@"
}

service_packages="bitcoin-mainnet bitcoin-rpc-proxy-mainnet electrs-mainnet nbxplorer-mainnet btcpayserver-system-mainnet lnd-mainnet ridetheln-system"

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

for _package in $service_packages;
do
	package_type["$_package"]="service"
done

# Avoid forgetting to set these
export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical
