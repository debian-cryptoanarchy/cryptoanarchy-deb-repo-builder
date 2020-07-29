#!/bin/bash

cfg_file="/etc/ridetheln-system/rtl.conf"
rt_file="/var/lib/ridetheln-system/RTL-Config.json"
rt_temp="$rt_file.tmp"

if [ -f "$rt_file" ];
then
	jq -s 'reduce .[] as $item ({}; . * $item)' "$rt_file" "$cfg_file" > "$rt_temp" || exit 1
else
	cp "$cfg_file" "$rt_temp" || exit 1
fi

chown ridetheln-system "$rt_temp"
chgrp ridetheln-system "$rt_temp"
sync "$rt_temp" || exit 1
mv "$rt_temp" "$rt_file" || exit 1
sync "$rt_file" || exit 1
