#!/bin/bash

set -e

sudo apt-get install -y btc-rpc-explorer

conf_file="/etc/btc-rpc-explorer-mainnet/btc-rpc-explorer.conf"

if [ "`sudo grep 'BTCEXP_ADDRESS_API=' "$conf_file"`" '!=' "BTCEXP_ADDRESS_API=" ];
then
	echo "BTCEXP_ADDRESS_API is set and should be:" >&2
	sudo grep 'BTCEXP_ADDRESS_API=' >&2
fi

sudo apt-get install -y electrs

if [ "`sudo grep 'BTCEXP_ADDRESS_API=' "$conf_file"`" '!=' "BTCEXP_ADDRESS_API=electrumx" ];
then
	echo "BTCEXP_ADDRESS_API not set and should be set to electrumx" >&2
fi

sudo apt-get purge -y electrs

if [ "`sudo grep 'BTCEXP_ADDRESS_API=' "$conf_file"`" '!=' "BTCEXP_ADDRESS_API=" ];
then
	echo "BTCEXP_ADDRESS_API is set and should be:" >&2
	sudo grep 'BTCEXP_ADDRESS_API=' >&2
fi
