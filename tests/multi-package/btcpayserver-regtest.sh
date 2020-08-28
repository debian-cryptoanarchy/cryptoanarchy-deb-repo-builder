#!/bin/bash

set -e

bitcoin_cli() {
	sudo bitcoin-cli -chain=regtest "$@"
}

test_dir="$(realpath "$(dirname "$0")/..")"

. "$test_dir/common.sh"

preload_config

echo '127.0.0.1 example.com' | sudo tee -a /etc/hosts >/dev/null

sudo apt install -y bitcoin-regtest bitcoin-cli lnd btcpayserver python3-selenium selfhost-clearnet python3-lnpbp-testkit

bitcoind_deposit_addr="`bitcoin_cli getnewaddress`"

echo "Generating coins to address $bitcoind_deposit_addr" >&2
bitcoin_cli generatetoaddress 101 "$bitcoind_deposit_addr"
sleep 10

echo "Starting selenium test" >&2
$test_dir/multi-package/btcpayserver-regtest/selenium_after_install.py
