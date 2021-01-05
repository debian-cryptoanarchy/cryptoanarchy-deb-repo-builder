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

function get_prune_value() {
	local config_file
	local prune_line
	local prune_value

	config_file="$1"
	# we don't use pipe because we prefer to kill the script in case of a problem
	prune_line="`grep '^ *prune *=' "$config_file"`" || exit 1
	echo $prune_line | sed -e 's/^ *prune *= *//' -e 's/ *$//' || exit 1
}

if [ -d "$conf_dir" ];
then
	# if the file doesn't exist it's first install
	if [ -f "$prev_chain_mode_file" ];
	then
		prev_prune_value="`get_prune_value "$prev_chain_mode_file"`"
		cur_prune_value="`get_prune_value "$chain_mode_file"`"
		# If pruning was enabled (different from 0) previously and it's disabled (0) now, we need to reindex
		# Note that txindex is handled by bitcoind, no need to check that.
		if [ "$prev_prune_value" != 0 ] && [ "$cur_prune_value" = 0 ];
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
