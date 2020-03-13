#!/bin/bash

. "/etc/btcpayserver-system-mainnet/btcpayserver-system-nginx-certbot-mainnet.conf" || exit 1

# Overrides used for testing
if [ -f "/etc/btcpayserver-system-mainnet/btcpayserver-system-nginx-certbot-mainnet.test.conf" ];
then
	. "/etc/btcpayserver-system-mainnet/btcpayserver-system-nginx-certbot-mainnet.test.conf" || exit 1
fi

if [ \! -d "/etc/letsencrypt/accounts" ];
then
	if [ "$eff_email" = "true" ];
	then
		eff_email_arg="--eff-email"
	else
		eff_email_arg="--no-eff-email"
	fi

	if echo "$CERTBOT_REGISTER_TEST_PARAM" | grep -q -- --register-unsafely-without-email;
	then
		certbot register --agree-tos $CERTBOT_REGISTER_TEST_PARAM "$eff_email_arg" < /dev/null >&2 || exit 1
	else
		if [ -z "$email" ];
		then
			echo "Failed to register with Let's encrypt: e-mail not provided" >&2
			exit 1
		fi

		certbot register --agree-tos $CERTBOT_REGISTER_TEST_PARAM --email "$email" "$eff_email_arg" < /dev/null >&2 || exit 1
	fi
fi

# If these files exist, we assume certbot will renew them whenever needed,
# so let's make sure certbot is run only once
if [ \! \( -f "/etc/btcpayserver-system-mainnet/tls/$btcpayserver_domain.fullchain" -a -f "/etc/btcpayserver-system-mainnet/tls/$btcpayserver_domain.key" \) ];
then
	mkdir -p /var/lib/btcpayserver-system-nginx-certbot-mainnet/webroot || exit 1
	chgrp www-data /var/lib/btcpayserver-system-nginx-certbot-mainnet/webroot || exit 1
	chmod 750 /var/lib/btcpayserver-system-nginx-certbot-mainnet/webroot || exit 1

	if echo "$CERTBOT_CERTONLY_TEST_PARAM" | grep -q -- --fake-cert;
	then
		openssl req -x509 -newkey rsa:4096 -keyout "/etc/btcpayserver-system-mainnet/tls/$btcpayserver_domain.key" -out "/etc/btcpayserver-system-mainnet/tls/$btcpayserver_domain.fullchain" -days 365 -subj='/CN='"$btcpayserver_domain" -nodes < /dev/null >&2
	else
		# The appropriate conf file configuring webroot was unpacked during installation
		# of this package, so we need to explicitly reload nginx first.
		# Trigger would fire too late.
		systemctl reload nginx || exit 1

		certbot certonly -q $CERTBOT_CERTONLY_TEST_PARAM -d "$btcpayserver_domain" --webroot --webroot-path "/var/lib/btcpayserver-system-nginx-certbot-mainnet/webroot" --cert-path "/etc/btcpayserver-system-mainnet/tls/$btcpayserver_domain.cert" --key-path "/etc/btcpayserver-system-mainnet/tls/$btcpayserver_domain.key" --fullchain-path "/etc/btcpayserver-system-mainnet/tls/$btcpayserver_domain.fullchain" --chain-path "/etc/btcpayserver-system-mainnet/tls/$btcpayserver_domain.chain" < /dev/null >&2 || exit 1
	fi
fi
