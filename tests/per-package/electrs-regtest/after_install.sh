#!/bin/bash

set -e

bitcoin_network="`echo -n $0 | sed 's/^.*-\([^-\/]*\)\/after_install\.sh$/\1/'`"

bitcoind_port=`sudo grep '^rpcport=' "/etc/bitcoin-$bitcoin_network/bitcoin.conf"`
bitcoind_port=`echo "$bitcoind_port" | sed 's/^rpcport=//'`

mining_addr="$(wget -O - --header "Authorization: Basic `sudo base64 -w 0 "/var/run/bitcoin-$bitcoin_network/cookie"`" --post-data='{"jsonrpc": "1.0", "id":"curltest", "method": "getnewaddress", "params": [] }' "http://127.0.0.1:$bitcoind_port/" | grep '"result"' | sed 's/^.*"result" *: *"\([^"]*\)".*$/\1/')"

wget -O - --header "Authorization: Basic `sudo base64 -w 0 "/var/run/bitcoin-$bitcoin_network/cookie"`" --post-data='{"jsonrpc": "1.0", "id":"curltest", "method": "generatetoaddress", "params": [100, "'"$mining_addr"'"] }' "http://127.0.0.1:$bitcoind_port/" | grep '"result"' | sed 's/^.*"result" *: *"\([^"]*\)".*$/\1/'

sleep 3

electrs_port="`grep '^ *electrum_rpc_addr *= *' "/etc/electrs-$bitcoin_network/conf.d/interface.toml"`"
electrs_port="`echo "$electrs_port" | sed 's/^ *electrum_rpc_addr *= *"[^:"]*:\([^"]*\)" *$/\1/'`"

echo '{ "id" : 0, "method": "server.version", "params": ["1.9.5", "0.10"] }' | nc -q 10 127.0.0.1 "$electrs_port" >&2
