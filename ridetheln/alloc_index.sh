#!/bin/bash

# This script atomically allocates index, starting from 1.

if [ $# -lt 2 ];
then
	echo "Usage: OUT_FILE DATA_DIR" >&2
	echo "OUT_FILE stores the allocated index" >&2
	echo "DATA_DIR stores the allocator data, usually /var/lib/ridetheln-index" >&2
	exit 1
fi

# Transparently handle the existing file so that tools using
# this alloator don't have to implement the logic.
if [ -e "$1" ];
then
	cat "$1"
	exit $?
fi

if [ '!' -d "$2" ];
then
	mkdir -p "$2" || exit 1
	chmod 750 "$2" || exit 1
fi

if [ '!' -d "`dirname "$1"`" ];
then
	mkdir -p "`dirname "$1"`" || exit 1
	chmod 750 "$2" || exit 1
fi

# Prevents multiple instances from modifying the data at the same time
exec 3<>"$2/lock" || exit 1
flock -x 3 || exit 1

# The following code makes sure to not corrupt index counter even if the
# machine shuts down at any moment.

# Check if previous operation failed
if [ -e "$2/last_index.tmp" ];
then
	# last_index is always valid or not existing
	if [ -e "$2/last_index" ];
	then
		# tmp might be invalid, so it's better to delete it
		rm -f "$2/last_index.tmp" || exit 1
	fi
fi

if [ -e "$2/last_index" ];
then
	last_index="`tr -d '\n' < "$2/last_index"`" || exit 1
else
	# This handles running the script for the first time, so it writes a warning to a visible file
	echo 'WARNING: Changes to data in this directory may lead to financial loss!' > "$2/_WARNING_README_" || exit 1
	last_index=0
fi

# This is overflow-safe because expr exits with failure on overflow
# 2^64 lightning nodes shouldn't happen anyway... :)
cur_index="`expr "$last_index" + 1`" || exit 1
echo "$cur_index" > "$2/last_index.tmp" || exit 1
# Avoid accidental overwrites
chmod 440 "$2/last_index.tmp"
echo "$cur_index" > "$1.tmp"
chmod 440 "$1.tmp"
sync "$2/last_index.tmp"
sync "$1.tmp"
# We assume mv is atomic. If not, we're screwed.
mv "$2/last_index.tmp" "$2/last_index" || exit 1
# Make sure the metadata is written to disk before proceeding
sync "$2/last_index"

# if this fails the index leaks, but it shouldn't be an issue
mv "$1.tmp" "$1" || exit 1
sync "$1"

flock -u 3 || exit 1

# We could also echo $cur_index, but this is a nice consistency check
cat "$1" || exit 1
