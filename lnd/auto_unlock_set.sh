#!/bin/bash

lnd_network="$1"

. /usr/share/lnd-auto-unlock/common.sh

set -e

atomic_store "$auto_unlock_config_file" <<EOF
DEBCRAFTER_EXTRA_SERVICE_ARGS=--wallet-unlock-password-file $password_file --wallet-unlock-allow-create
EOF

dpkg-trigger /etc/lnd-system-regtest/conf.d
