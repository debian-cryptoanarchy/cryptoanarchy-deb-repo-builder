#!/bin/bash

set -e

test_dir="`dirname "$0"`"

. "$test_dir/common_vars.sh"

sudo mkdir -p /etc/selfhost
sudo cp "$test_data_dir/clearnet-certbot.test.conf"  /etc/selfhost
