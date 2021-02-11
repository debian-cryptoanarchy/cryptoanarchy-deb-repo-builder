#!/bin/bash

function replace_libnssckbi() {
	# TODO: support other archs
	dpkg-divert --rename --package selfhost-clearnet-certbot --add "$1" || exit 1
	ln -s /usr/lib/x86_64-linux-gnu/pkcs11/p11-kit-trust.so "$1"
}

. "/etc/selfhost/clearnet-certbot.conf" || exit 1

# Overrides used for testing
if [ -f "/etc/selfhost/clearnet-certbot.test.conf" ];
then
	. "/etc/selfhost/clearnet-certbot.test.conf" || exit 1
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
		#certbot register --agree-tos $CERTBOT_REGISTER_TEST_PARAM "$eff_email_arg" < /dev/null >&2 || exit 1
		true
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
if [ \! \( -f "/etc/selfhost/tls/$domain.fullchain" -a -f "/etc/selfhost/tls/$domain.key" \) ];
then
	mkdir -p /etc/selfhost/tls || exit 1
	chmod 700 /etc/selfhost/tls || exit 1

	mkdir -p /var/lib/selfhost-clearnet-certbot/webroot || exit 1
	chgrp www-data /var/lib/selfhost-clearnet-certbot || exit 1
	chgrp www-data /var/lib/selfhost-clearnet-certbot/webroot || exit 1
	chmod 750 /var/lib/selfhost-clearnet-certbot/webroot || exit 1

	if echo "$CERTBOT_CERTONLY_TEST_PARAM" | grep -q -- --fake-cert;
	then
		mkdir -p -m 700 /etc/selfhost-clearnet-certbot/test-ca
		if [ '!' -e "/etc/selfhost-clearnet-certbot/test-ca/ca.pem" ];
		then
			openssl req -x509 -newkey rsa:4096 \
				-keyout "/etc/selfhost-clearnet-certbot/test-ca/ca.key" \
				-out "/etc/selfhost-clearnet-certbot/test-ca/ca.pem" \
				-days 365 -subj='/CN='"TestCA" -nodes < /dev/null >&2 || exit 1
		fi
		if [ '!' -e "/etc/selfhost/tls/$domain.csr" ];
		then
			openssl req -newkey rsa:4096  -keyout "/etc/selfhost/tls/$domain.key"  -out "/etc/selfhost/tls/$domain.csr"  -subj='/CN='"$domain" -nodes < /dev/null >&2 || exit 1
		fi
		cp "/etc/selfhost-clearnet-certbot/test-ca/ca.pem" "/usr/local/share/ca-certificates/test_ca.crt" || exit 1
		# TODO: support other archs
		replace_libnssckbi /usr/lib/x86_64-linux-gnu/nss/libnssckbi.so
		replace_libnssckbi /usr/lib/firefox-esr/libnssckbi.so
		replace_libnssckbi /usr/lib/thunderbird/libnssckbi.so
		dpkg-trigger update-ca-certificates || exit 1
		openssl x509 -req -days 365 \
			-in "/etc/selfhost/tls/$domain.csr" \
			-CA "/etc/selfhost-clearnet-certbot/test-ca/ca.pem" \
			-CAkey "/etc/selfhost-clearnet-certbot/test-ca/ca.key" -CAcreateserial \
			-out "/etc/selfhost/tls/$domain.fullchain"
	else
		# The appropriate conf file configuring webroot was unpacked during installation
		# of this package, so we need to explicitly reload nginx first.
		# Trigger would fire too late.
		systemctl reload nginx || exit 1

		if [ \! \( -f "/etc/letsencrypt/live/$domain/fullchain.pem" -a -f "/etc/letsencrypt/live/$domain/privkey.pem" \) ];
		then
			certbot certonly -q $CERTBOT_CERTONLY_TEST_PARAM -d "$domain" --webroot \
				--webroot-path "/var/lib/selfhost-clearnet-certbot/webroot" < /dev/null >&2 || exit 1
		fi

		ln -sf "/etc/letsencrypt/live/$domain/fullchain.pem" "/etc/selfhost/tls/$domain.fullchain" || exit 1
		ln -sf "/etc/letsencrypt/live/$domain/privkey.pem" "/etc/selfhost/tls/$domain.key" || exit 1
	fi
fi

certbot plugins --prepare || exit 1

# Enable TLS only after certs were generated, nginx will fail otherwise
mkdir -p /etc/selfhost/clearnet-enabled || exit 1
ln -sf /etc/selfhost/clearnet-wip/tls.conf /etc/selfhost/clearnet-enabled/tls.conf || exit 1
dpkg-trigger /etc/selfhost/clearnet-enabled || exit 1
