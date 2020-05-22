#!/bin/bash

if sudo grep -q '^prune=0$' /etc/bitcoin-mainnet/bitcoin.conf;
then
	echo 'Pruning turned off - OK'
else
	echo 'Error: pruning turned on'
	exit 1
fi

if sudo grep -q '^txindex=1$' /etc/bitcoin-mainnet/bitcoin.conf;
then
	echo 'Error: txindex needlessly enabled for electrs'
	exit 1
fi
