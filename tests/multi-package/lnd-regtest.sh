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

sudo apt-get install -y lnd-system-regtest bitcoin-cli lncli

"$test_dir/lib/spawn_secondary_lnd.sh" 1 9800

system_lnd_pubkey="`sudo lncli --network regtest getinfo | grep identity_pubkey | sed 's/^ *"identity_pubkey" *: *"\([^"]*\)".*$/\1/'`"


deposit_addr="`tlncli 1 newaddress p2wkh | grep address | sed 's/^.*"address" *: *"\([^"]*\)".*$/\1/'`"

bitcoin_cli generatetoaddress 110 "$deposit_addr"

sleep 10

tlncli 1 openchannel --connect "127.0.0.1:9737" "$system_lnd_pubkey" 10000000

sleep 3

bitcoin_cli generatetoaddress 10 "$deposit_addr"

sleep 10

invoice="`sudo lncli --network regtest addinvoice --amt 1000 | grep '"payment_request"' | sed 's/^.*"payment_request" *: *"\([^"]*\)".*$/\1/'`"

tlncli 1 payinvoice -f "$invoice"

sleep 3

sudo lncli --network regtest listinvoices | grep -q '"SETTLED"'
