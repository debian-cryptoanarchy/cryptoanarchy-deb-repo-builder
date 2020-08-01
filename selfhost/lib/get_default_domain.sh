#!/bin/bash

first_onion_domain=""

for conf in /etc/selfhost/domains/*;
do
	domain="`grep '^domain:' "$conf" | sed 's/^domain: *"\([^"]*\)"$/\1/' | tr -s '\n'`"
	grep -q '^tls_cert:' "$conf" && domain="https://$domain" || domain="http://$domain"
	if echo "$domain" | grep -q '\.onion$';
	then
		test -z "$first_onion_domain" && first_onion_domain="$domain"
	else
		echo -n "$domain"
		exit 0
	fi
done

echo -n "$first_onion_domain"
