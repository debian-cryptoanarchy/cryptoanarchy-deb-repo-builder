#!/bin/bash

# Runs PHP with added settings from FPM pool configuration file in order to stay in sync

php_version="`dpkg-query --showformat '${Version}' -W php-fpm | sed -e 's/^2://' -e 's/[+-].*$//'`"
extra_args="`grep '^php_value\[' "/etc/php/$php_version/fpm/pool.d/nextcloud-server-system.conf" | sed 's/^php_value\[\([^]]*\)\] *= *\([^ ].*\)$/-d \1=\2/'`"

export NEXTCLOUD_CONFIG_DIR=/var/lib/nextcloud-server-system/config
export PHP_MEMORY_LIMIT=512M

cd /usr/share/nextcloud-server || exit 1

exec /usr/bin/php $extra_args -f "$@"
