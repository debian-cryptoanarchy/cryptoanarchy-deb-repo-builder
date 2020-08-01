#!/bin/bash

check_network() {
	local network="$1"
	local conf_file="/etc/selfhost/apps/thunderhub-system-$network.conf"
	local run_dir="/var/run/thunderhub-system-$network"
	local cookie_file="$run_dir/sso/cookie"

	if [ -d "$run_dir" ];
	then
		if [ -r "$conf_file" ];
		then
			# getting the value is split in order to do proper error handling
			if root_path="`grep '^root_path:' "$conf_file"`";
			then
				root_path="`echo "$root_path" | sed 's/^root_path: *"\(.*\)"$/\1/'`" || exit 1
			else
				echo "Error: root_path not found in $conf_file" >&2
			fi
		else
			echo "You don't have permission to  access $conf_file, try with sudo" >&2
			exit 1
		fi

		if [ -r "$cookie_file" ];
		then
			cookie="`cat $cookie_file`" || exit 1
		else
			echo "You don't have permission to  access $cookie_file, try with sudo" >&2
		fi

		return 0
	else
		return 1
	fi
}

if [ -n "$1" ];
then
	if check_network "$1";
	then
		network="$1"
	else
		echo "ThunderHub is not running with bitcoin network $1" >&2
		exit 1
	fi

else
	for network in mainnet regtest;
	do
		check_network "$network" && break
	done

	if [ -z "$cookie" ];
	then
		echo "ThunderHub is not running or you don't have thunderhub-system-mainnet or thunderhub-system-regtest installed" >&2
		exit 1
	fi
fi

domain="`/usr/share/selfhost/lib/get_default_domain.sh`" || exit 1

if [ -z "$domain" ];
then
	echo "Unknown domain, looks like you didn't setup selfhost properly" >&2
	dpkg --get-selections 2>/dev/null | grep -q '^selfhost-onion[ \t]' &>/dev/null || echo "Maybe install selfhost-onion?" >&2
fi

link="$domain$root_path?token=$cookie"

if [ -n "$DISPLAY" ] && which xdg-open &>/dev/null;
then
	echo "Opening ThunderHub on network $network" >&2
	# We don't want to run the browser under root
	if [ "$EUID" -eq 0 -a -n "$SUDO_USER" ];
	then
		sudo="sudo -u $SUDO_USER"
	fi
	# We can't simply run xdg-open $link because $link is secret and
	# That would show in ps aux, so we work around it by storing the
	# link in a temporary HTML document with the redirect and opening that.
	helper_page="`$sudo mktemp --suffix .html`"
	$sudo tee "$helper_page" &>/dev/null <<EOF
<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="refresh" content="0; url='$link'" />
  </head>
  <body>
    <p><a href="$link">Open ThunderHub</a></p>
  </body>
</html>
EOF
	$sudo xdg-open "$helper_page"
	ret=$?
	$sudo rm -f "$helper_page"
	exit $ret
else
	echo "It looks like you aren't using a desktop environment." >&2
	echo "Please visit the following link to access ThunderHub" >&2
	echo "$link"
fi
