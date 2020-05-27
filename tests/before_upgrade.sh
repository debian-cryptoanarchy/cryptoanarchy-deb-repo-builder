#!/bin/bash

set -e

test_dir="`dirname "$0"`"
pkg_dir="$1"
packages="$2"

. "$test_dir/common.sh"

"$test_dir/setup_deb_ln_ask_me.sh" "--internal-test"

preload_config
sudo mkdir -p /etc/selfhost
sudo cp "$test_data_dir/clearnet-certbot.test.conf"  /etc/selfhost/
sudo apt install -y $packages
