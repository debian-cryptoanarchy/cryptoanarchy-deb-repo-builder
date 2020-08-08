#!/bin/bash

set -e

# Replace . with \. for use in grep
lndconnect_onion=`sudo sed 's/\./\\./' /var/lib/tor/lndconnect_hidden_service/hostname | tr -d '\n'`

if sudo lndconnect | grep -q '^lndconnect://'"$lndconnect_onion"':[1-9][0-9]*?cert=[a-zA-Z0-9_-]\+&macaroon=[a-zA-Z0-9_-]\+';
then
	echo "lndconnect link looks OK" >&2
else
	echo "Unexpected lndconnect link" >&2
	sudo lndconnect
	exit 1
fi

if openssl x509 -text < /var/lib/lnd-system-mainnet/public/tls.cert | grep -q "DNS:$lndconnect_onion";
then
	echo "Certificate OK" >&2
else
	echo "Certificate missing domain $lndconnect_onion" >&2
	exit 1
fi
