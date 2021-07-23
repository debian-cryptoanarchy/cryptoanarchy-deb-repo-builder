#!/bin/bash

lnd_network="$BITCOIN_NETWORK"

. /usr/share/lnd-auto-unlock/common.sh

# We don't use lncli because it's useless for seed initialization
lnd_call() {
	if [ -n "$2" ];
	then
		# We need to post data using a temp file to avoid leaking the seed on command line
		post_file="--post-file=$2"
	fi

	wget -O - --ca-certificate "$lnd_cert_file" $post_file "https://127.0.0.1:$lnd_rest_port/v1/$1"
	return $?
}

umask 177

if [ '!' -e "$password_file" ];
then
	echo -n "$wallet_password_unencoded" | atomic_store "$password_file"
fi

# Give LND some time to bind ports/process macaroons
sleep 3

# When LND is not initialized yet, macaroon file doesn't exist. It's created during initialization.
# So we can use its' existence to determine if we need to initialize or unlock.
# If an admin removes it, he breaks more stuff than just auto unlocker, so we don't care.
if [ '!' -e "$lnd_admin_macaroon_file" ];
then
	# Generate the seed
	if [ '!' -e "$seed_file" ];
	then
		# Robust initialization:
		# 1. Call /genseed and store it in a temp file
		# 2. Sync temp file
		# 3. Move temp file to dest location
		# 4. Init the wallet with the generated seed
		lnd_call genseed | jq .cipher_seed_mnemonic > "$tmp_seed_file" || exit 1
		sync "$tmp_seed_file" || exit 1
		mv "$tmp_seed_file" "$seed_file" || exit 1
	fi

	# We re-use tmp_seed_file because it's stored in a safe location
	jq '{ wallet_password: "'"$wallet_password"'", cipher_seed_mnemonic: . }' "$seed_file" > "$tmp_seed_file" || exit 1
	ret=1
	for x in `seq 1 10`;
	do
		if lnd_call initwallet "$tmp_seed_file";
		then
			ret=0
			break
		fi
		sleep 10
	done
	ret=$?
	rm -f "$tmp_seed_file"
	if [ $ret -eq 0 ];
	then
		lnd_wait_init
		chmod 640 "$lnd_admin_macaroon_file"
	fi
	exit $ret
fi
