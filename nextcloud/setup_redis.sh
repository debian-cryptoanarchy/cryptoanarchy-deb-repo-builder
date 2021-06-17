#!/bin/bash

set -e

nextcloud_redis_config_file="/var/lib/nextcloud-server-system/config/redis.config.php"
nextcloud_redis_config_file_tmp="$nextcloud_redis_config_file.tmp"
redis_config_file="/etc/nextcloud-server-redis/redis.conf"
redis_socket_line="`grep '^unixsocket ' "$redis_config_file"`"
redis_unix_socket="`echo "$redis_socket_line=" | sed 's/^unixsocket //'`"

cat > $nextcloud_redis_config_file_tmp <<EOF
<?php

\$CONFIG = [
'memcache.distributed' => '\\OC\\Memcache\\Redis',
'redis' => [
     'host'     => '/run/nextcloud-server-redis/redis.sock',
     'port'     => 0,
     'dbindex'  => 0,
     'timeout'  => 1.5,
]
];
EOF

sync "$nextcloud_redis_config_file_tmp"
mv "$nextcloud_redis_config_file_tmp" "$nextcloud_redis_config_file"
