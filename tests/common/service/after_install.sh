#!/bin/bash

package_name="$1"
service_name="$package_name.service" # they are same by default

# We wait some time to see if the service crashes
sleep 1m

if sudo systemctl is-active --quiet "$service_name";
then
	echo "Service $service_name is running" >&2
else
	echo "Service $service_name failed"
	sudo journalctl -xeu "$service_name"
	exit 1
fi
