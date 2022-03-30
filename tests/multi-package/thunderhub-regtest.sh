#!/bin/bash

set -e

test_dir="$(realpath "$(dirname "$0")/..")"

. "$test_dir/common.sh"

preload_config

echo '127.0.0.1 example.com' | sudo tee -a /etc/hosts >/dev/null

sudo apt-get install -y bitcoin-regtest lnd thunderhub python3-selenium selfhost-clearnet python3-lnpbp-testkit

echo "Starting selenium test" >&2
$test_dir/multi-package/thunderhub-regtest/selenium_after_install.py
