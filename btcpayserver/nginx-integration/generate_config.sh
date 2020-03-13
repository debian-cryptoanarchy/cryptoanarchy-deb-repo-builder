#!/bin/bash

# Remove the links in order to avoid inconsistency
# Start with removing the top link in order to keep the configuration consistent
if rm -f /etc/nginx/sites-enabled/cryptoanarchy-node.conf;
then
	rm -f /etc/nginx/cryptoanarchy-subsites-enabled/cryptoanarchy-node.conf || exit 1
else
	exit 1
fi

mustache "/etc/btcpayserver-system-mainnet/btcpayserver-system-nginx-mainnet.conf" /usr/share/btcpayserver-system-nginx-mainnet/config_top_template.mustache > /etc/nginx/sites-available/cryptoanarchy-node.conf || exit 1
mkdir -p /etc/nginx/cryptoanarchy-subsites-available || exit 1
mustache "/etc/btcpayserver-system-mainnet/btcpayserver-system-nginx-mainnet.conf" /usr/share/btcpayserver-system-nginx-mainnet/config_sub_template.mustache > /etc/nginx/cryptoanarchy-subsites-available/btcpayserver-system-mainnet.conf || exit 1

mkdir -p /etc/nginx/cryptoanarchy-subsites-enabled || exit 1
ln -sf /etc/nginx/cryptoanarchy-subsites-available/btcpayserver-system-mainnet.conf /etc/nginx/cryptoanarchy-subsites-enabled/ || exit 1
ln -sf /etc/nginx/sites-available/cryptoanarchy-node.conf /etc/nginx/sites-enabled/ || exit 1

# Verify the configuration to improve robustness
if /usr/sbin/nginx -t;
then
	# If this fails, we're screwed even more, but we have no way to fix that
	rm -f /etc/nginx/sites-enabled/cryptoanarchy-node.conf
	exit 1
else
	dpkg-trigger nginx-reload || exit 1
fi
