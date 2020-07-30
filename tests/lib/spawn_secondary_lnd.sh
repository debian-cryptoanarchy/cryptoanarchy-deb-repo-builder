#!/bin/bash

set -e

if [ -z "$1" ];
then
	echo "Missing instance name" >&2
	exit 1
fi

if [ -z "$2" ];
then
	echo "Missing port" >&2
	exit 1
fi

name="$1"
port="$2"

rest_port="$(expr "$port" + 1)"
grpc_port="$(expr "$port" + 2)"

user_name="lnd-test-$name"
home_dir="/var/lib/$user_name"
bitcoind_port=18443

sudo adduser --system --group --home "$home_dir" "$user_name"
sudo -u $user_name mkdir -p "$home_dir/.lnd"
sudo -u $user_name tee "$home_dir/.lnd/lnd.conf" >/dev/null <<EOF
noseedbackup=1
alias=$1
bitcoin.defaultchanconfs=1
color=#$(echo "$name" | sha256sum | cut -c 1-6)
debuglevel=info
listen=0.0.0.0:$port
restlisten=0.0.0.0:$rest_port
rpclisten=0.0.0.0:$grpc_port
bitcoin.active=1
bitcoin.regtest=1
bitcoin.node=bitcoind
bitcoind.rpchost=127.0.0.1:$bitcoind_port
bitcoind.rpcpass=public
bitcoind.rpcuser=public
bitcoind.zmqpubrawblock=tcp://127.0.0.1:28442
bitcoind.zmqpubrawtx=tcp://127.0.0.1:28443
EOF

sudo -u "$user_name" lnd &

sleep 10
