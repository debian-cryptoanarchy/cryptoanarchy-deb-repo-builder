#!/bin/bash

bucket_size_file_temp="/etc/nginx/conf.d/bucket_size.tmp"
bucket_size_file_conf="/etc/nginx/conf.d/bucket_size.conf"

case "$1" in
	"apps")
		avail_dir="/etc/nginx/selfhost-subsites-available"
		enabled_dir="/etc/nginx/selfhost-subsites-enabled"
		input_dir="/etc/selfhost/apps"
		template_file="/usr/share/selfhost-nginx/config_sub_template.mustache"
		prepare_cb=true
		;;
	"domains")
		avail_dir="/etc/nginx/sites-available"
		enabled_dir="/etc/nginx/sites-enabled"
		input_dir="/etc/selfhost/domains"
		template_file="/usr/share/selfhost-nginx/config_top_template.mustache"
		prepare_cb=check_bucket_size
		bucket_size=64
		;;
	*)
		echo "Invalid input" >&2
		echo "Usage: $0 apps|domains" >&2
		exit 1
		;;
esac

function check_bucket_size() {
	len="`grep '^domain:' "$1" | sed 's/^domain: *//' | wc -c`" || return 1
	if [ "$len" -gt "$bucket_size" ];
	then
		bucket_size="`echo -e 'import math\nprint(2 ** math.ceil(math.log('$len', 2)))' | python3`"
		echo "server_names_hash_bucket_size $bucket_size;" > "$bucket_size_file_temp"
		sync "$bucket_size_file_temp"
		mv "$bucket_size_file_temp" "$bucket_size_file_conf"
	fi
}

function process_item() {
	input_config_name="$1"
	output_config="$2"
	output_link="$3"

	"$prepare_cb" "$input_config_name" || return 1

	# Remove the link in order to avoid inconsistency
	rm -f "$output_link" || return 1
	mustache "$input_config_name" "$template_file" > "$output_config" || return 1
	sync "$output_config" || return 1
	ln -sf "$output_config" "$output_link" || return 1

	# Verify the configuration to improve robustness
	if /usr/sbin/nginx -t;
	then
		echo -n
	else
		# If this fails, we're completely screwed, so safer to kill the whole thing
		rm -f "$output_link" || exit 1
		return 1
	fi
}

# Skip the whole thing if no app is available
if [ -d "$input_dir" ] && [ "`ls "$input_dir" | wc -l`" -gt 0 ];
then
	mkdir -p "$avail_dir" || exit 1
	mkdir -p "$enabled_dir" || exit 1

	failed=0
	cd "$input_dir" || exit 1
	for input_config_name in *;
	do
		output_config="$avail_dir/$input_config_name"
		output_link="$enabled_dir/$input_config_name"

		rm -f "$output_link"
		process_item "$input_config_name" "$output_config" "$output_link" || failed=1
	done

	# Reload nginx regardless of fails, since some apps might be working
	dpkg-trigger nginx-reload || failed=1
	exit $failed
else
	exit 0
fi
