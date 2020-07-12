#!/bin/bash

network="`echo -n $0 | sed 's/^.*-\([^-\/]*\)\/after_install\.sh$/\1/'`"

if echo "$network" | grep -q '^[a-z]\+$';
then
	echo -n
else
	echo "Can't determine network from argument: $0"
	exit 1
fi

port="`grep '^restlisten=' /etc/lnd-system-$network/lnd.conf | sed 's/^restlisten=[^:]*://'`" || exit 1

assert_exists() {
	if sudo [ '!' -e "$1" ];
	then
		echo "Error: File doesn't exist: $1"
		exit 1
	fi
}

getinfo() {
	wget -O /dev/null --ca-certificate /var/lib/lnd-system-$network/public/tls.cert --header "Grpc-Metadata-macaroon: `sudo xxd -ps -u -c 1000 /var/lib/lnd-system-$network/private/admin.macaroon`" https://127.0.0.1:$port/v1/getinfo
	return $?
}

sleep 20

assert_exists /var/lib/lnd-system-$network/.seed.txt
assert_exists /var/lib/lnd-system-$network/private/admin.macaroon
assert_exists /var/lib/lnd-system-$network/readonly/readonly.macaroon
assert_exists /var/lib/lnd-system-$network/invoice/invoice.macaroon

if sudo ls -l /var/lib/lnd-system-$network/private/admin.macaroon | grep -q '^-rw-r----- ';
then
	echo 'Permissions OK'
else
	echo 'Bad permissions on /var/lib/lnd-system-$network/private/admin.macaroon:'
	ls -l /var/lib/lnd-system-$network/private/admin.macaroon
	sudo exit 1
fi

# TODO: parse as json and check it's an array of 12 strings
if [ `sudo cat /var/lib/lnd-system-$network/.seed.txt | wc -c` -eq 0 ];
then
	echo 'Error: Seed is empty'
	exit 1
fi

getinfo || exit 1

sudo systemctl stop lnd-system-$network
sleep 5

# Make sure the service stopped
getinfo && exit 1

sudo systemctl start lnd-system-$network
sleep 15

getinfo || exit 1
