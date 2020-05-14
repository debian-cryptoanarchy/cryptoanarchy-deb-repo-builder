#!/bin/bash

package_name="$1"
service_name="$package_name" # they are same by default

sleep 1m

if sudo systemctl is-active --quiet "$service_name";
then
	echo "$service_name is still running after removal" >&2
	journalctl -eu "$service_name"
	exit 1
else
	echo "$service_name successfully removed" >&2
fi
