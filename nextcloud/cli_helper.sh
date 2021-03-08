#!/bin/bash

# Runs PHP with added settings from FPM pool configuration file in order to stay in sync

extra_args="`grep '^php_value\[' "/etc/php/7.3/fpm/pool.d/nextcloud-server-system.conf" | sed 's/^php_value\[\([^]]*\)\] *= *\([^ ].*\)$/-d \1=\2/'`"

export NEXTCLOUD_CONFIG_DIR=/var/lib/nextcloud-server-system/config
export PHP_MEMORY_LIMIT=512M

exec /usr/bin/php $extra_args -f "$@"
