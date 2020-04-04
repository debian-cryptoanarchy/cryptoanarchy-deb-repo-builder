#!/bin/bash

# Remove the links in order to avoid inconsistency
rm -f /etc/nginx/selfhost-subsites-enabled/apps.conf || exit 1

mkdir -p /etc/nginx/selfhost-subsites-available || exit 1
mustache "/etc/selfhost/apps.conf" /usr/share/selfhost-nginx/config_sub_template.mustache > /etc/nginx/selfhost-subsites-available/apps.conf || exit 1

mkdir -p /etc/nginx/selfhost-subsites-enabled || exit 1
ln -sf /etc/nginx/selfhost-subsites-available/apps.conf /etc/nginx/selfhost-subsites-enabled/ || exit 1

# Verify the configuration to improve robustness
if /usr/sbin/nginx -t;
then
	dpkg-trigger nginx-reload || exit 1
else
	# If this fails, we're screwed even more, but we have no way to fix that
	rm -f /etc/nginx/sites-enabled/selfhost.conf
	exit 1
fi
