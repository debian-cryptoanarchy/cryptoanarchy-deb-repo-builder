#!/bin/bash

if sudo grep '^dbcache=450$' /etc/bitcoin-regtest/bitcoin.conf && 
   [ `grep MemTotal /proc/meminfo | awk '{{print $2}}'` -ge 1024000 ];
then
	echo "Failed to override dbcache" >&2
	exit 1
fi

until sudo systemctl is-active bitcoin-regtest;
do
	sleep 1
done

if ps aux | grep -v grep | grep -q 'bitcoind.*-reindex' || sudo journalctl --no-pager -u bitcoin-regtest | grep -q 'Reindexing';
then
	echo "Error: unneeded reindex" >&2
	exit 1
fi

if sudo test -e "/var/lib/bitcoin-regtest/regtest/wallets/test_wallet";
then
	wget -O - --post-data='{"jsonrpc": "1.0", "id":"curltest0", "method": "loadwallet", "params": ["test_wallet"] }' --header 'content-type: text/plain;' --header 'Authorization: Basic '"`sudo cat /var/run/bitcoin-regtest/cookie | base64 | tr -d '\n'`" "http://127.0.0.1:`sudo grep '^rpcport=' /etc/bitcoin-regtest/bitcoin.conf | sed 's/^rpcport=//' | tr -d '\n'`"
else
	wget -O - --post-data='{"jsonrpc": "1.0", "id":"curltest0", "method": "createwallet", "params": ["test_wallet"] }' --header 'content-type: text/plain;' --header 'Authorization: Basic '"`sudo cat /var/run/bitcoin-regtest/cookie | base64 | tr -d '\n'`" "http://127.0.0.1:`sudo grep '^rpcport=' /etc/bitcoin-regtest/bitcoin.conf | sed 's/^rpcport=//' | tr -d '\n'`"
fi

if gen_addr="$(wget -O - --post-data='{"jsonrpc": "1.0", "id":"curltest0", "method": "getnewaddress", "params": [] }' --header 'content-type: text/plain;' --header 'Authorization: Basic '"`sudo cat /var/run/bitcoin-regtest/cookie | base64 | tr -d '\n'`" "http://127.0.0.1:`sudo grep '^rpcport=' /etc/bitcoin-regtest/bitcoin.conf | sed 's/^rpcport=//' | tr -d '\n'`" | sed 's/^.*"result" *: *"\([^"]*\)".*$/\1/')";
then
	echo Generating 150 blocks to address "$gen_addr" >&2
	if wget -O - --post-data='{"jsonrpc": "1.0", "id":"curltest1", "method": "generatetoaddress", "params": [150, "'"$gen_addr"'"] }' --header 'content-type: text/plain;' --header 'Authorization: Basic '"`sudo cat /var/run/bitcoin-regtest/cookie | base64 | tr -d '\n'`" "http://127.0.0.1:`sudo grep '^rpcport=' /etc/bitcoin-regtest/bitcoin.conf | sed 's/^rpcport=//' | tr -d '\n'`";
	then
		echo "Succcess generating 150 blocks" >&2
	else
		echo "Failed to generate blocks" >&2
		exit 1
	fi
else
	echo "Failed to get an address for generating coins" >&2
	exit 1
fi
