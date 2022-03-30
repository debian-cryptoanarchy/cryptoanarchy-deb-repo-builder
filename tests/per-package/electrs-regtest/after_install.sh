#!/bin/bash

set -e

until sudo systemctl is-active bitcoin-regtest;
do
	sleep 1
done

bitcoin_network="`echo -n $0 | sed 's/^.*-\([^-\/]*\)\/after_install\.sh$/\1/'`"

sleep 10

electrs_port="`grep '^ *electrum_rpc_addr *= *' "/etc/electrs-$bitcoin_network/conf.d/interface.toml"`"
electrs_port="`echo "$electrs_port" | sed 's/^ *electrum_rpc_addr *= *"[^:"]*:\([^"]*\)" *$/\1/'`"

for i in {0..3}; do
	if echo '{ "id" : 0, "method": "server.version", "params": ["1.9.5", "0.10"] }' | nc -q 10 127.0.0.1 "$electrs_port" >&2; then
		break
	elif [ $i -eq 3 ]; then
		echo "Failed to connect to electrs-regtest"
		exit 1
	fi
	sleep 2
done
