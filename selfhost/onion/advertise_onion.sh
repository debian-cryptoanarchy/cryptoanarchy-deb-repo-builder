#!/bin/bash

hostname_file="/var/lib/tor/selfhost_hidden_service/hostname"
conf_dir="/etc/nginx/selfhost-clearnet-conf.d"
conf_file="$conf_dir/onion_location.conf"
tmp_conf_tile="$conf_file.tmp"

if [ -e "$hostname_file" ];
then
	hostname="`tr -d '\n ' < "$hostname_file"`" || exit 0
	mkdir -p -m 750 "$conf_dir"
	echo "add_header Onion-Location http://$hostname"'$request_uri;' > "$tmp_conf_tile"
	sync "$tmp_conf_tile"
	mv "$tmp_conf_tile" "$conf_file"
fi
