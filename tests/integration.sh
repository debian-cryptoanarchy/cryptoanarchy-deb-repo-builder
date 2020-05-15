#!/bin/bash

set -e

test_dir="`dirname "$0"`"
pkg_dir="$1"

. "$test_dir/common.sh"

packages="bitcoind bitcoin-mainnet bitcoin-pruned-mainnet bitcoin-fullchain-mainnet bitcoin-txindex-mainnet bitcoin-zmq-mainnet bitcoin-rpc-proxy bitcoin-rpc-proxy-mainnet bitcoin-timechain-mainnet electrs electrs-mainnet btcpayserver btcpayserver-system-mainnet btcpayserver-system-selfhost-mainnet lnd lnd-system-mainnet ridetheln ridetheln-system ridetheln-system-selfhost ridetheln-lnd-system-mainnet selfhost selfhost-nginx selfhost-onion selfhost-clearnet selfhost-clearnet-certbot tor-hs-patch-config"
# pruned, txindex and fullchain conflict, so we only install txindex
non_conflict_packages="`echo $packages | tr ' ' '\n' | grep -v bitcoin-fullchain | grep -v bitcoin-pruned`"

"$test_dir/prepare_machine.sh" "$pkg_dir"

for package in $packages;
do
	"$test_dir/package_clean_install.sh" "$pkg_dir" "$package"
done

echo "Basic test done, preparing upgrade test" >&2
sudo mv "$apt_repo_dir" "$apt_repo_dir.tmp"
"$test_dir/before_upgrade.sh" "$pkg_dir" "$non_conflict_packages"

"$test_dir/prepare_machine.sh" "$pkg_dir"

for package in $non_conflict_packages;
do
	"$test_dir/upgrade_package.sh" "$pkg_dir" "$package"
done
