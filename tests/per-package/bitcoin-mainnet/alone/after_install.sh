#!/bin/bash

if dpkg --get-selections | grep -q $'bitcoin-pruned-mainnet[ \t]*install$';
then
	echo "bitcoin-mainnet has pruning enabled - OK" >&2
else
	echo "Error: bitcoin-mainnet seems to have pruning disabled" >&2
	exit 1
fi

if dpkg --get-selections | grep -E $'bitcoin-(txindex|fullchain)-mainnet[ \t]install$' >&2;
then
	echo "Error: conflicting package(s) found - see above" >&2
	exit 1
fi
