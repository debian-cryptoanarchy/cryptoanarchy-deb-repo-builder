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

getinfo() {
	wget -O /dev/null --ca-certificate "$lnd_cert_file" --header "Grpc-Metadata-macaroon: `sudo xxd -ps -u -c 1000 "$lnd_admin_macaroon_file"`" https://127.0.0.1:$lnd_rest_port/v1/getinfo
	return $?
}

sleep 20

assert_exists /var/lib/lnd-system-$lnd_network/.seed.txt
assert_exists "$lnd_admin_macaroon_file"
assert_exists "$lnd_invoice_macaroon_file"
assert_exists "$lnd_readonly_macaroon_file"

if sudo ls -l "$lnd_admin_macaroon_file" | grep -q '^-rw-r----- ';
then
	echo 'Permissions OK'
else
	echo "Bad permissions on $lnd_admin_macaroon_file:"
	sudo ls -l "$lnd_admin_macaroon_file"
	exit 1
fi

# TODO: parse as json and check it's an array of 12 strings
if [ `sudo cat /var/lib/lnd-system-$lnd_network/.seed.txt | wc -c` -eq 0 ];
then
	echo 'Error: Seed is empty'
	exit 1
fi

getinfo || exit 1

sudo systemctl stop lnd-system-$lnd_network
sleep 5

# Make sure the service stopped
getinfo && exit 1

sudo systemctl start lnd-system-$lnd_network
sleep 15

getinfo || exit 1
