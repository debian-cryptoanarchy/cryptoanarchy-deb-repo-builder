#!/bin/bash

set -e

bitcoin_cli() {
	sudo bitcoin-cli -chain=regtest "$@"
}

tlncli() {
	user="$1"
	shift
	sudo -u "lnd-test-$user" /usr/lib/lncli/lncli --network regtest --rpcserver "127.0.0.1:9802" "$@"
}

test_dir="$(realpath "$(dirname "$0")/..")"

. "$test_dir/common.sh"

preload_config

echo '127.0.0.1 example.com' | sudo tee -a /etc/hosts >/dev/null

sudo apt install -y bitcoin-regtest bitcoin-cli lnd btcpayserver python3-selenium selfhost-clearnet lncli

# Initialize testing network

echo "Setting up a secondary LND" >&2
"$test_dir/lib/spawn_secondary_lnd.sh" 1 9800 &> ~/secondary_lnd_log

# f*** LND takes ages to load
sleep 10

# Wait for lnd to figure out its pubkey
system_lnd_pubkey=""
while [ -z "$system_lnd_pubkey" ];
do
	sleep 10
	echo "Attempting to get the pubkey of the system LND"
	system_lnd_pubkey="`sudo lncli --network regtest getinfo | grep identity_pubkey | sed 's/^ *"identity_pubkey" *: *"\([^"]*\)".*$/\1/'`"
done

sys_lnd_deposit_addr=""
while [ -z "$sys_lnd_deposit_addr" ];
do
	sleep 10
	echo "Attempting to get a deposit address of the secondary LND"
	sys_lnd_deposit_addr="`sudo lncli --network regtest newaddress p2wkh | grep address | sed 's/^.*"address" *: *"\([^"]*\)".*$/\1/'`"
done

sec_lnd_deposit_addr=""
while [ -z "$sec_lnd_deposit_addr" ];
do
	sleep 10
	echo "Attempting to get a deposit address of the secondary LND"
	sec_lnd_deposit_addr="`tlncli 1 newaddress p2wkh | grep address | sed 's/^.*"address" *: *"\([^"]*\)".*$/\1/'`"
done

bitcoind_deposit_addr="`bitcoin_cli getnewaddress`"

echo "Generating coins to address $sys_lnd_deposit_addr" >&2
bitcoin_cli generatetoaddress 5 "$sys_lnd_deposit_addr"

echo "Generating coins to address $sec_lnd_deposit_addr" >&2
bitcoin_cli generatetoaddress 5 "$sec_lnd_deposit_addr"

echo "Generating coins to address $bitcoind_deposit_addr" >&2
bitcoin_cli generatetoaddress 110 "$bitcoind_deposit_addr"
sleep 10

echo "Opening a channel with $system_lnd_pubkey" >&2
tlncli 1 openchannel --connect "127.0.0.1:9737" "$system_lnd_pubkey" 10000000

sleep 3

echo "Generating a few blocks to confirm the channel" >&2
bitcoin_cli generatetoaddress 10 "$sys_lnd_deposit_addr"

sleep 10

echo "Starting selenium test" >&2
$test_dir/multi-package/btcpayserver-regtest/selenium_after_install.py
