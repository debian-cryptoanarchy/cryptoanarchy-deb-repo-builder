#!/bin/bash

# We use exit 0 everywhere because this is not essential feature

network="$1"
p2p_port="`echo $2 | sed 's/^.*://'`"
hidden_service_dir="/var/lib/tor/lnd_${network}_hidden_service"

domain=""
if [ -x "/usr/share/selfhost/lib/get_default_domain.sh" -a -d /etc/selfhost/domains ] && [ "`ls /etc/selfhost/domains | wc -l`" -gt 0 ];
then
	domain="`/usr/share/selfhost/lib/get_default_domain.sh | sed 's/^https\?:\/\///'`" || exit 0
	if echo "$domain" | grep -q '\.onion$';
	then
		domain=""
	fi
fi

if [ -z "$domain" -a -d /etc/tor/hidden-services.d ] && grep 'include /etc/tor/hidden-services\.d' /usr/share/tor/tor-service-defaults-torrc &>/dev/null;
then
	tmp_conf=/etc/tor/hidden-services.d/.lnd.conf.tmp
	echo "HiddenServiceDir $hidden_service_dir" > "$tmp_conf"
	echo "HiddenServicePort $p2p_port 127.0.0.1:$p2p_port" >> "$tmp_conf"
	sync "$tmp_conf"
	mv "$tmp_conf" "/etc/tor/hidden-services.d/lnd.conf"

	# Even if Tor package had a trigger it'd be useless
	deb-systemd-invoke restart tor@default.service || exit 0

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
fi

echo -n "$domain"
