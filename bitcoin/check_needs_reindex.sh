#!/bin/bash

# This script checks if bitcoind needs -reindex and creates a marker file if it does
# Currently the check only detects going from pruned to non-pruned chain.
# DB corruption and such are not attempted.
# Such can be implemented in the future.

network="$1"

if [ -z "$network" ];
then
	echo "Error: missing argument - bitcoin network" 2>&1
fi

. /usr/share/bitcoind/definitions.sh || exit 1

if [ -d "$conf_dir" ];
then
	# if the file doesn't exist it's first install
	if [ -f "$prev_chain_mode_file" ];
	then
		# If pruning was enabled (different from 0) previously and it's disabled (0) now, we need to reindex
		# Note that txindex is handled by bitcoind, no need to check that.
		if grep -qv '^ *prune *= *0 *$' "$prev_chain_mode_file" && grep -q '^ *prune *= *0 *$' "$chain_mode_file";
		then
			echo "Info: The chain will be reindexed after restart" >&2
			touch "$needs_reindex_marker_file"
		fi
	fi

	# Remember current configuration as previous
	cp "$chain_mode_file" "$prev_chain_mode_tmp_file" || exit 1
	sync "$prev_chain_mode_tmp_file" || exit 1
	mv "$prev_chain_mode_tmp_file" "$prev_chain_mode_file" || exit 1
else
	echo "$conf_dir doesn't exist, perhaps wrong argument?" >&2
	exit 1
fi
