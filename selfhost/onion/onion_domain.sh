#!/bin/bash

hostname_file="/var/lib/tor/selfhost_hidden_service/hostname"
selfhost_conf=/etc/tor/hidden-services.d/selfhost.conf

# Just read the hostname if it was created already
if [ -e "$hostname_file" ];
then
	tr -d '\n ' < "$hostname_file"
	exit $?
fi

if [ '!' -e "$selfhost_conf" ];
then
	ln -sf /usr/share/selfhost-onion/hidden_service.conf "$selfhost_conf" || exit 1
fi

which inotifywait &>/dev/null && use_inotify=1 || use_inotify=0

# reload-or-restart doesn't actually start the service when not active
if systemctl is-active -q tor@default.service;
then
	systemctl reload-or-restart tor@default.service || exit 1
else
	systemctl start tor@default.service || exit 1
fi

retries=0
while [ '!' -e "$hostname_file" ] && [ $retries -lt 5 ];
do
	# The timeout patches the race condition that the file might be created after
	# check and before running inotifywait.
	test "$use_inotify" -eq 1 && inotifywait -q -q -e close_write -t 2 >&2 || sleep 2
	retries=`expr $retries + 1`
done

tr -d '\n ' < "$hostname_file"
exit $?
