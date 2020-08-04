#!/bin/bash

set -e

if sudo lndconnect | grep -q '^lndconnect://[^:]*:[1-9][0-9]*?cert=[a-zA-Z0-9_-]\+&macaroon=[a-zA-Z0-9_-]\+';
then
	echo "lndconnect link looks OK" >&2
else
	echo "Unexpected lndconnect link" >&2
	sudo lndconnect
	exit 1
fi
