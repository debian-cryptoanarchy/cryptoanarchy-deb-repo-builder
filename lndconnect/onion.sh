#!/bin/bash

set -e

conf="/etc/tor/hidden-services.d/lndconnect.conf"
tmp_conf="/etc/tor/hidden-services.d/.lndconnect.conf.tmp"

# yes, this should go somewhere else, not sure where.
chgrp debian-tor /etc/tor/hidden-services.d

ports=""
for network in mainnet regtest;
do
	lnd_network="$network"
	# We have to clear these variables each time.
	# The values from previous include will stay there otherwise.
	lnd_grpc_port=""
	lnd_config_file=""
	. /usr/share/lnd/lib/bash.sh &>/dev/null

	if [ -n "$lnd_grpc_port" ];
	then
		ports="$ports $lnd_grpc_port"
	fi
done

if [ -n "$ports" ];
then
	echo "HiddenServiceDir /var/lib/tor/lndconnect_hidden_service" > "$tmp_conf"
	for port in $ports;
	do
		echo "HiddenServicePort $port 127.0.0.1:$port" >> "$tmp_conf"
	done

	sync "$tmp_conf"
	mv "$tmp_conf" "$conf"

	needs_reload=1
else
	if [ -e "$conf" ];
	then
		needs_reload=1
	else
		needs_reload=0
	fi
	rm -f "$conf"
fi

if [ $needs_reload ];
then
	# Unfortunately, Tor package doesn't have trigger, so we need to reload directly
	if systemctl is-active -q tor@default.service;
	then
		deb-systemd-invoke reload-or-restart tor@default.service || exit 1
	else
		deb-systemd-invoke start tor@default.service || exit 1
	fi
fi
