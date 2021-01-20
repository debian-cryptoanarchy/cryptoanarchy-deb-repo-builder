#!/bin/bash

network="$1"

if [ -z "$network" ];
then
	echo "Error: missing argument - bitcoin network" 2>&1
else
	if . /usr/share/bitcoind/definitions.sh;
	then
		rm -f "$needs_reindex_marker_file"
	fi
fi
