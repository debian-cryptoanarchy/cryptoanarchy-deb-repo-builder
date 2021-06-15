#!/bin/bash

. /etc/cadr-policy/policy.conf

service="$1"
package="$2"
installed_by="$3"

if [ '!' -d "/var/lib/cadr-policy/disabled-services/$service/" ];
then
	exit 0
fi

rm -f "/var/lib/cadr-policy/disabled-services/$service/$installed_by"

if [ "`ls "/var/lib/cadr-policy/disabled-services/$service/" | wc -l`" -eq 0 ];
then
	echo "Re-enabling $service" >&2
	systemctl enable "$service"
	rmdir "/var/lib/cadr-policy/disabled-services/$service/"
fi
