#!/bin/bash

cfg_file="/etc/ridetheln-system/rtl.conf"
rt_file="/var/lib/ridetheln-system/RTL-Config.json"
rt_temp="$rt_file.tmp"

rt_dir="`dirname "$rt_file"`"
mkdir -p "$rt_dir"
chown ridetheln-system "$rt_dir"
chgrp ridetheln-system "$rt_dir"
mkdir -p "$rt_dir/sso"
chown ridetheln-system "$rt_dir/sso"
chgrp ridetheln-system-sso "$rt_dir/sso"
chmod 750 "$rt_dir/sso"

if [ -f "$rt_file" ];
then
	jq -s 'reduce .[] as $item ({}; . * $item)' "$rt_file" "$cfg_file" > "$rt_temp" || exit 1
else
	cp "$cfg_file" "$rt_temp" || exit 1
fi

sync "$rt_temp" || exit 1
mv "$rt_temp" "$rt_file" || exit 1
sync "$rt_file" || exit 1
