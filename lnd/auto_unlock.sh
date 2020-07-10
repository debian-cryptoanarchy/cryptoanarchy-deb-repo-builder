#!/bin/bash

network="$BITCOIN_NETWORK"

get_option() {
	grep '^'"$1"'[ \t]*=' /etc/lnd-system-$network/lnd.conf | sed 's/^'"$1"'[ \t]*=[ \t]*//' | tr -d '\n'
}

# We don't use lncli because it's useless for seed initialization
lnd_call() {
	if [ -n "$2" ];
	then
		# We need to post data using a temp file to avoid leaking the seed on command line
		post_file="--post-file=$2"
	fi

	wget -O - --ca-certificate "$cert_file" $post_file "https://127.0.0.1:$rest_port/v1/$1"
	return $?
}

lnd_home="/var/lib/lnd-system-$network"
seed_file="$lnd_home/.seed.txt"
tmp_seed_file="$lnd_home/.seed.txt.tmp"
macaroon_file="`get_option adminmacaroonpath`"
cert_file="`get_option tlscertpath`"
rest_port="`get_option restlisten | sed 's/^.*://'`"
# We use fixed wallet password.
# See https://github.com/lightningnetwork/lnd/issues/899
# Run with FDE if you're concerned.
wallet_password="`echo -n lnd password is counterproductive | base64`"

# Robust initialization:
# 1. Call /genseed and store it in a temp file
# 2. Sync temp file
# 3. Move temp file to dest location
# 4. Init the wallet with the generated seed

umask 177

# Give LND some time to bind ports
sleep 3

if [ '!' -e "$seed_file" ];
then
	lnd_call genseed | jq .cipher_seed_mnemonic > "$tmp_seed_file" || exit 1
	sync "$tmp_seed_file" || exit 1
	mv "$tmp_seed_file" "$seed_file" || exit 1
fi

# When LND is not initialized yet, macaroon file doesn't exist. It's created during initialization.
# So we can use its' existence to determine if we need to initialize or unlock.
# If an admin removes it, he breaks more stuff than just auto unlocker, so we don't care.
if [ -e "$macaroon_file" ];
then
	# Fix permissions of admin.macaroon to allow group access
	# This is in case something prevents this command to run after init
	chmod 640 "$macaroon_file"
	# The password is fixed and small, so using shm makes the most sense
	tmp_post_data="`mktemp /dev/shm/lnd-unlock.XXXXXXX`"
	echo '{"wallet_password": "'"$wallet_password"'"}' > "$tmp_post_data"
	lnd_call unlockwallet "$tmp_post_data"
	ret=$?
	rm -f "$tmp_post_data"
	exit $ret
else
	# We re-use tmp_seed_file because it's stored in a safe location
	jq '{ wallet_password: "'"$wallet_password"'", cipher_seed_mnemonic: . }' "$seed_file" > "$tmp_seed_file" || exit 1
	lnd_call initwallet "$tmp_seed_file"
	ret=$?
	rm -f "$tmp_seed_file"
	if [ $ret -eq 0 ];
	then
		while [ '!' -e "$macaroon_file" ];
		do
			if which inotifywait &>/dev/null
			then
				inotifywait -e create "`dirname "$macaroon_file"`" || sleep 1
			else
				sleep 1
			fi
		done
		chmod 640 "$macaroon_file"
	fi
	exit $ret
fi
