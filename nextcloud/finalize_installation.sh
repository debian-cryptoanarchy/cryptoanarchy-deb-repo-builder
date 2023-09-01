#!/bin/bash

set -e

current_php_version="`dpkg-query --showformat '${Version}' -W php-fpm | sed -e 's/^2://' -e 's/[+-].*$//'`"
old_php_version="`grep -v '^#' /etc/nextcloud-server-system/php_version 2>/dev/null`" || old_php_version="7.3"
user_name="nextcloud-server-system"
group_name="$user_name"
nextcloud_selfhost_resource_dir="/usr/share/nextcloud-server-system"
etc_conf_dir="/etc/nextcloud-server-system"
data_dir="/var/lib/nextcloud-server-system/data"
internal_conf_dir="/var/lib/nextcloud-server-system/config"
main_config_file_src="$etc_conf_dir/nextcloud.conf"
main_config_file="$internal_conf_dir/config.php"
main_config_file_tmp="$main_config_file.tmp"
caldav_config_file="$etc_conf_dir/caldav.conf"
caldav_config_file_tmp="$caldav_config_file.tmp"
carddav_config_file="$etc_conf_dir/carddav.conf"
carddav_config_file_tmp="$carddav_config_file.tmp"
db_conf_file_src="/$etc_conf_dir/database"
db_conf_file_dst="$internal_conf_dir/database.config.php"
db_conf_file_dst_tmp="$db_conf_file_dst.tmp"
admin_pass_file="$internal_conf_dir/admin_pass.config.php"
admin_pass_file_tmp="$admin_pass_file.tmp"
selfhost_config="$internal_conf_dir/selfhost.config.php"
selfhost_config_tmp="$selfhost_config.tmp"
apcu_config="$internal_conf_dir/apcu.config.php"
apcu_config_tmp="$apcu_config.tmp"
nginx_conf_file="/etc/nginx/nextcloud-server.conf"
nginx_conf_file_tmp="$nginx_conf_file.tmp"
cache_dir="/var/cache/nextcloud-server"
fpm_log_dir="/var/log/nextcloud-server-system"
current_fpm_config_file="/etc/php/$current_php_version/fpm/pool.d/nextcloud-server-system.conf"
old_fpm_config_file="/etc/php/$old_php_version/fpm/pool.d/nextcloud-server-system.conf"

adduser --system --quiet --group --home "/var/lib/$user_name" "$user_name"
mkdir -p -m 750 "$internal_conf_dir"
chown "$user_name":"$user_name" "$internal_conf_dir"
mkdir -p -m 750 "$data_dir"
chown "$user_name":"$user_name" "$data_dir"
mkdir -p -m 750 "$cache_dir"
chown "$user_name":"$user_name" "$cache_dir"

if [ '!' -e "$current_fpm_config_file" ];
then
	if [ -e "$old_fpm_config_file" ];
	then
		if [ -L "$old_fpm_config_file" ];
		then
			mv "$old_fpm_config_file" "$current_fpm_config_file"
			dpkg-trigger --no-await "/etc/php/$old_php_version/fpm/conf.d"
		else
			mv -T "$old_fpm_config_file" "$etc_conf_dir/fpm-pool.conf"
			dpkg-trigger --no-await "/etc/php/$old_php_version/fpm/conf.d"
			ln -s "$etc_conf_dir/fpm-pool.conf" "$current_fpm_config_file"
		fi
	else
		ln -s "$etc_conf_dir/fpm-pool.conf" "$current_fpm_config_file"
	fi
	dpkg-trigger --await "/etc/php/$current_php_version/fpm/conf.d"
fi

echo -e '# Internal, do not change!\n'"$current_php_version" > /etc/nextcloud-server-system/php_version.tmp
sync /etc/nextcloud-server-system/php_version.tmp
mv /etc/nextcloud-server-system/php_version.tmp /etc/nextcloud-server-system/php_version

if [ '!' -e "$main_config_file" ];
then
	cp "$nextcloud_selfhost_resource_dir/default_config.php" "$main_config_file_tmp"
	chown "$user_name" "$main_config_file_tmp"
	chmod 640 "$main_config_file_tmp"
	sync "$main_config_file_tmp"
	mv "$main_config_file_tmp" "$main_config_file"
fi

mustache "/etc/selfhost/apps/nextcloud-system.conf" "$nextcloud_selfhost_resource_dir/nginx_template.mustache" > "$nginx_conf_file_tmp"
sync "$nginx_conf_file_tmp"
mv "$nginx_conf_file_tmp" "$nginx_conf_file"

. "$db_conf_file_src"

if [ -z "$dbc_port" ];
then
	dbc_port=5432
fi

touch "$db_conf_file_dst_tmp"
chown "$user_name:$user_name" "$db_conf_file_dst_tmp"
chmod 640 "$db_conf_file_dst_tmp"

cat <<EOF > "$db_conf_file_dst_tmp"
<?php

\$CONFIG = [
'dbtype' => 'pgsql',
'dbhost' => '$dbc_server:$dbc_port',
'dbname' => '$dbc_dbname',
'dbuser' => '$dbc_user',
'dbpassword' => '$dbc_password'
];
EOF
sync "$db_conf_file_dst_tmp"
mv "$db_conf_file_dst_tmp" "$db_conf_file_dst"

admin_pass="`head -c 18 /dev/urandom | base64`"

touch "$admin_pass_file_tmp"
chown "$user_name:$user_name" "$admin_pass_file_tmp"
chmod 640 "$admin_pass_file_tmp"

if [ '!' -e "$admin_pass_file" ];
then
cat <<EOF > "$admin_pass_file_tmp"
<?php

\$CONFIG = [
'adminpass' => '$admin_pass',
];
EOF
sync "$admin_pass_file_tmp"
mv "$admin_pass_file_tmp" "$admin_pass_file"
fi

cat <<EOF > "$selfhost_config_tmp"
<?php

\$CONFIG = [
'trusted_domains' => [
EOF

chown "$user_name:$user_name" "$selfhost_config_tmp"
chmod 640 "$selfhost_config_tmp"
for conf in /etc/selfhost/domains/*;
do
        domain="`grep '^domain:' "$conf" | sed 's/^domain: *"\([^"]*\)"$/\1/' | tr -s '\n'`"
	echo "'$domain'," >> "$selfhost_config_tmp"
done

. "$main_config_file_src"

cat <<EOF >> "$selfhost_config_tmp"
],
'overwritewebroot' => '$root_path',
];
EOF
sync "$selfhost_config_tmp"
mv "$selfhost_config_tmp" "$selfhost_config"

cat <<EOF >> "$caldav_config_file_tmp"
location = /.well-known/caldav {
	return 301 $root_path/remote.php/dav/;
}
EOF
sync "$caldav_config_file_tmp"
mv "$caldav_config_file_tmp" "$caldav_config_file"

cat <<EOF >> "$carddav_config_file_tmp"
location = /.well-known/carddav {
	return 301 $root_path/remote.php/dav/;
}
EOF
sync "$carddav_config_file_tmp"
mv "$carddav_config_file_tmp" "$carddav_config_file"

if [ -e "/etc/php/$php_version/mods-available/apcu.ini" ];
then
cat <<EOF > "$apcu_config_tmp"
<?php

\$CONFIG = [
'memcache.local' => '\\OC\\Memcache\\APCu',
];
EOF
	sync "$apcu_config_tmp"
	mv "$apcu_config_tmp" "$apcu_config"
else
	rm -f "$apcu_config" "$apcu_config_tmp"
fi

mkdir -p -m 750 "$fpm_log_dir"
chown "$user_name":"$user_name" "$fpm_log_dir"

if grep -q "'installed' => true," "$main_config_file";
then
	echo "Nextcloud server already installed"
else
	setpriv --reuid="$user_name" --regid="$group_name" --init-groups --no-new-privs -- /usr/share/nextcloud-server-system/cli_helper.sh occ maintenance:install
	# Having weather app on a server is ridiculous and possibly privacy leaking
	setpriv --reuid="$user_name" --regid="$group_name" --init-groups --no-new-privs -- /usr/share/nextcloud-server-system/cli_helper.sh occ app:disable weather_status
fi

systemctl enable --now nextcloud-server-periodic.timer
