#!/bin/bash

lnd_network="`echo -n $0 | sed 's/^.*-\([^-\/]*\)\/after_install\.sh$/\1/'`"

if echo "$lnd_network" | grep -q '^[a-z]\+$';
then
	echo -n
else
	echo "Can't determine network from argument: $0"
	exit 1
fi

. /usr/share/lnd/lib/bash.sh

assert_exists() {
	if sudo [ '!' -e "$1" ];
	then
		echo "Error: File doesn't exist: $1"
		exit 1
	fi
}

lnd_call() {
	method="$1"
	shift
	if [ -n "$1" ];
	then
		post_data='--post-data'
	fi

	wget -O /dev/null --ca-certificate "$lnd_cert_file" --header "Grpc-Metadata-macaroon: `sudo xxd -ps -u -c 1000 "$lnd_admin_macaroon_file"`" $post_data "$@" https://127.0.0.1:$lnd_rest_port/v1/"$method"
	return $?
}

invoice_readonly_macaroon="/var/lib/lnd-system-$lnd_network/invoice/invoice+readonly.macaroon"

sleep 1m

assert_exists "$invoice_readonly_macaroon"

lnd_call "getinfo" || exit 1
# This command gets stuck, probably due to chain not being synced :(
#lnd_call "invoices" '{}' || exit 1

if sudo ls -l "$invoice_readonly_macaroon" | grep -q '^-rw-r----- ';
then
	echo 'Permissions OK'
else
	echo "Bad permissions on $invoice_readonly_macaroon:"
	sudo ls -l "$invoice_readonly_macaroon"
	exit 1
fi
