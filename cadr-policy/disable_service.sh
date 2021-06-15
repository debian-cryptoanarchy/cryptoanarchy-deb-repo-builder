#!/bin/bash

. /etc/cadr-policy/policy.conf

service="$1"
package="$2"
installed_by="$3"

if systemctl is-enabled "$service" &>/dev/null;
then
	mkdir -p /var/lib/cadr-policy/disabled-services/$service/
else
	if [ -d "/var/lib/cadr-policy/disabled-services/$service/" ];
	then
		echo "Service $service already disabled" >&2
	else
		echo "Service $service already disabled by administrator" >&2

		mkdir -p /var/lib/cadr-policy/disabled-services-tmp/$service/
		touch /var/lib/cadr-policy/disabled-services-tmp/$service/_already_disabled
		sync /var/lib/cadr-policy/disabled-services-tmp/$service/_already_disabled
		mv -T /var/lib/cadr-policy/disabled-services-tmp/$service/ /var/lib/cadr-policy/disabled-services/$service
		rmdir /var/lib/cadr-policy/disabled-services-tmp/ &>/dev/null

		touch /var/lib/cadr-policy/disabled-services/$service/$installed_by
		exit 0
	fi
fi

touch /var/lib/cadr-policy/disabled-services/$service/$installed_by

if [ "$disable_unneeded_services" '!=' "true" ];
then
	echo "Not disabling possibly unneeded $service because cadr-policy says not to" >&2
	exit 0
fi

if apt-show "$package" 2>/dev/null | grep -q '^APT-Manual-Installed: yes$';
then
	echo "Not disabling $service because it's manually installed" >&2
else
	for dep in `apt-cache rdepends --no-recommends --no-suggests --no-enhances --no-breaks --no-replaces --no-conflicts $package --installed | sed -n '/^Reverse Depends:/,$p'| grep -v '^Reverse Depends:'`;
	do
		if [ '!' -e "/var/lib/cadr-policy/disabled-services/$service/$dep" ];
		then
			echo "Not disabling $service because $dep depends on it" >&2
			exit 0
		fi
	done

	echo "Disabling $service" >&2
	systemctl disable "$service"
	systemctl stop "$service"
fi
