#!/bin/bash

set -e

test_dir="`dirname "$0"`"
pkg_dir="$1"
packages="$2"

. "$test_dir/common.sh"

sudo cp "$test_data_dir/experimental_apt.list" /etc/apt/sources.list.d/cryptoanarchy-experimental.list
sudo apt-key add < "$test_data_dir/experimental_key.gpg"
sudo apt update
sudo apt install -y $packages
