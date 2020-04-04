#!/bin/bash

# Remove the links in order to avoid inconsistency
rm -f /etc/nginx/sites-enabled/selfhost.conf || exit 1

# Skip the whole thing if no domain is available
if [ -d /etc/selfhost/domains ];
then
	if [ "`ls /etc/selfhost/domains | wc -l`" -eq 0 ];
	then
		exit 0
	fi
else
	exit 0
fi

mustache "/etc/selfhost/domains.conf" /usr/share/selfhost-nginx/config_top_template.mustache > /etc/nginx/sites-available/selfhost.conf || exit 1

ln -sf /etc/nginx/sites-available/selfhost.conf /etc/nginx/sites-enabled/ || exit 1

# Verify the configuration to improve robustness
if /usr/sbin/nginx -t;
then
	dpkg-trigger nginx-reload || exit 1
else
	# If this fails, we're screwed even more, but we have no way to fix that
	rm -f /etc/nginx/sites-enabled/selfhost.conf
	exit 1
fi
