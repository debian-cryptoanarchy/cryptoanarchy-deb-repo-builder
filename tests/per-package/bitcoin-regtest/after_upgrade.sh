#!/bin/bash

if ps aux | grep -v grep | grep -q 'bitcoind.*-reindex' || sudo journalctl --no-pager -u bitcoin-regtest | grep -q 'Reindexing';
then
	echo "Error: unneeded reindex" >&2
	exit 1
fi
