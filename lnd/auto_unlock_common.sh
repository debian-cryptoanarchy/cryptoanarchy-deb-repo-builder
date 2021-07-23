#!/bin/bash

. /usr/share/lnd/lib/bash.sh

atomic_store() {
	local dest_file="$1"
	local tmp_file="$dest_file.tmp"

	cat > "$tmp_file" || return 1
	sync "$tmp_file" || return 1
	mv "$tmp_file" "$dest_file"
}

lnd_home="/var/lib/lnd-system-$lnd_network"
seed_file="$lnd_home/.seed.txt"
tmp_seed_file="$lnd_home/.seed.txt.tmp"
# We use fixed wallet password.
# See https://github.com/lightningnetwork/lnd/issues/899
# Run with FDE if you're concerned.
password_file="/usr/share/lnd-auto-unlock/static_password"
wallet_password="`base64 < "$password_file"`"
auto_unlock_config_file="/var/lib/lnd-system-$lnd_network/.auto_unlock"
