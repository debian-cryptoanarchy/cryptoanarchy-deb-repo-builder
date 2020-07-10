#!/bin/bash

assert_exists() {
	if sudo [ '!' -e "$1" ];
	then
		echo "Error: File doesn't exist: $1"
		exit 1
	fi
}

getinfo() {
	wget -O /dev/null --ca-certificate /var/lib/lnd-system-mainnet/public/tls.cert --header "Grpc-Metadata-macaroon: `sudo xxd -ps -u -c 1000 /var/lib/lnd-system-mainnet/private/admin.macaroon`" https://127.0.0.1:9090/v1/getinfo
	return $?
}

assert_exists /var/lib/lnd-system-mainnet/.seed.txt
assert_exists /var/lib/lnd-system-mainnet/private/admin.macaroon
assert_exists /var/lib/lnd-system-mainnet/readonly/readonly.macaroon
assert_exists /var/lib/lnd-system-mainnet/invoice/invoice.macaroon

# TODO: parse as json and check it's an array of 12 strings
if [ `sudo cat /var/lib/lnd-system-mainnet/.seed.txt | wc -c` -eq 0 ];
then
	echo 'Error: Seed is empty'
	exit 1
fi

getinfo || exit 1

sudo systemctl stop lnd-system-mainnet
sleep 5

# Make sure the service stopped
getinfo && exit 1

sudo systemctl start lnd-system-mainnet
sleep 15

getinfo || exit 1
