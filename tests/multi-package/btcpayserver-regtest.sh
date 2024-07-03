#!/bin/bash

set -e

test_dir="$(realpath "$(dirname "$0")/..")"

. "$test_dir/common.sh"

preload_config

echo '127.0.0.1 example.com' | sudo tee -a /etc/hosts >/dev/null

if [ -z "$DBUS_SESSION_BUS_ADDRESS" ];
then
	sudo systemctl start dbus.service
	sudo systemctl start user@$UID.service
	export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$UID/bus
	export XDG_RUNTIME_DIR=/run/user/$UID
fi

sudo apt-get install -y bitcoin-regtest lnd btcpayserver python3-selenium selfhost-clearnet python3-lnpbp-testkit

echo "Starting selenium test" >&2
$test_dir/multi-package/btcpayserver-regtest/selenium_after_install.py
