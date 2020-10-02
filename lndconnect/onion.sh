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

hidden_service_dir="/var/lib/tor/lndconnect_hidden_service"

if [ -n "$ports" ];
then
	echo "HiddenServiceDir $hidden_service_dir" > "$tmp_conf"
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
	deb-systemd-invoke restart tor@default.service || exit 1
fi

for x in `seq 1 60`;
do
	# This checks if the file exists and if writing to it finished
	if grep '\.onion$' "$hidden_service_dir/hostname" &>/dev/null;
	then
		domain="`cat "$hidden_service_dir/hostname"`"
		break
	fi
	sleep 1
done

if [ -z "$domain" ];
then
	echo "Failed to setup onion domain for lndconnect"
	exit 1
fi

for network in mainnet regtest;
do
	ext_conf="/etc/lnd-system-$network/conf.d/lndconnect.conf"
	ext_conf_tmp="/etc/lnd-system-$network/.lndconnect.conf.tmp"
	echo "tlsextradomain=$domain" > "$ext_conf_tmp"
	echo "tlsautorefresh=1" >> "$ext_conf_tmp"
	sync "$ext_conf_tmp"
	mv "$ext_conf_tmp" "$ext_conf"
done
