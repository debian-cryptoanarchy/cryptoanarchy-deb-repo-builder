#!/bin/bash

if dpkg --get-selections | grep -q $'bitcoin-pruned-regtest[ \t]*install$';
then
	echo "bitcoin-regtest has pruning enabled - OK" >&2
else
	echo "Error: bitcoin-regtest seems to have pruning disabled" >&2
	exit 1
fi

if dpkg --get-selections | grep -E $'bitcoin-(txindex|fullchain)-regtest[ \t]install$' >&2;
then
	echo "Error: conflicting package(s) found - see above" >&2
	exit 1
fi

sleep 30

if wget -O - --post-data='{"jsonrpc": "1.0", "id":"curltest", "method": "getblockchaininfo", "params": [] }' --header 'content-type: text/plain;' --header 'Authorization: Basic '"`sudo cat /var/run/bitcoin-regtest/cookie | base64 | tr -d '\n'`" "http://127.0.0.1:`sudo grep '^rpcport=' /etc/bitcoin-regtest/bitcoin.conf | sed 's/^rpcport=//' | tr -d '\n'`" | grep -q '"chain":"regtest"';
then
	echo 'Chain is correct' >&2
else
	echo 'Bad chain:'
	wget -O - --post-data='{"jsonrpc": "1.0", "id":"curltest", "method": "getblockchaininfo", "params": [] }' --header 'content-type: text/plain;' --header 'Authorization: Basic '"`sudo cat /var/run/bitcoin-regtest/cookie | base64 | tr -d '\n'`" "http://127.0.0.1:`sudo grep '^rpcport=' /etc/bitcoin-regtest/bitcoin.conf | sed 's/^rpcport=//' | tr -d '\n'`"
	exit 1
fi
