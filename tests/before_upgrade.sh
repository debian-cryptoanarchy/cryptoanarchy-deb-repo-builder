#!/bin/bash

set -e

test_dir="`dirname "$0"`"
pkg_dir="$1"
upgrade_from="$2"
packages="$3"

. "$test_dir/common.sh"

test -n "$DPKG_DEBUG_LEVEL" && echo "debug $DPKG_DEBUG_LEVEL" | sudo tee /etc/dpkg/dpkg.cfg.d/cadr-test >/dev/null

"$test_dir/setup_deb_ln_ask_me.sh" "$upgrade_from" "--internal-test"

preload_config
sudo mkdir -p /etc/selfhost
sudo cp "$test_data_dir/clearnet-certbot.test.conf"  /etc/selfhost/
sudo apt-get install -y $packages
