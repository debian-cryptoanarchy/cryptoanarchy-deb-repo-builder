#!/bin/bash

# Runs PHP with added settings from FPM pool configuration file in order to stay in sync

function check_php_version() {
	if [ -z "$1" ];
	then
		return 0
	fi

	if ! dpkg --compare-versions "$1" "$2" "$3"; then
		if [ "$MAINTSCRIPT_ACTION" = "upgrade" ] || [ "$MAINTSCRIPT_ACTION" = "failed-upgrade" ]; then
			echo "$4">&2
			exit 0
		else
			echo "Incompatible PHP version installed - the following condition failed: $1 $2 $3"
			exit 1
		fi
	fi
}

function check_dep_installed() {
	if [ "`dpkg-query --showformat '${db:Status-Status}' -W "$1"`" '!=' "installed" ];
	then
		if [ "$MAINTSCRIPT_ACTION" = "upgrade" ] || [ "$MAINTSCRIPT_ACTION" = "failed-upgrade" ]; then
			echo "The dependency $1 of nextcloud-server is not installed, skipping maintainer script action $*">&2
			exit 0
		else
			echo "The dependency $1 of nextcloud-server is not installed">&2
			exit 1
		fi
	fi
}

nextcloud_deps="`dpkg-query --showformat '${Depends}' -W nextcloud-server`" || exit 1

php_deps="`echo "$nextcloud_deps" | tr ',' '\n' | grep '^php.*' | sed 's/ (.*)//'`"

for dep in $php_deps;
do
	check_dep_installed "$dep"
	php_package_version="`dpkg-query --showformat '${Version}' -W "$dep"`" || exit 1
	min_php_version="`echo $nextcloud_deps | sed -n 's/.*'"$dep"' (>= \([^)]*\)).*/\1/p'`" || exit 1
	check_php_version "$php_package_version" ge "$min_php_version" "The nextcloud-server package was upgraded before upgrading PHP - skipping maintainer script action $*"

	incompatible_php_version="`echo $nextcloud_deps | sed -n 's/.*'"$dep"' (<< \([^)]*\)).*/\1/p'`" || exit 1
	check_php_version "$php_package_version" lt "$incompatible_php_version" "PHP was upgraded before upgrading nextcloud-server - skipping maintainer script action $*"
done

php_fpm_version="`dpkg-query --showformat '${Version}' -W php-fpm | sed -e 's/^2://' -e 's/[+-].*$//'`" || exit 1

extra_args="`grep '^php_value\[' "/etc/php/$php_fpm_version/fpm/pool.d/nextcloud-server-system.conf" | sed 's/^php_value\[\([^]]*\)\] *= *\([^ ].*\)$/-d \1=\2/'`"

export NEXTCLOUD_CONFIG_DIR=/var/lib/nextcloud-server-system/config
export PHP_MEMORY_LIMIT=512M

cd /usr/share/nextcloud-server || exit 1

exec /usr/bin/php $extra_args -f "$@"
