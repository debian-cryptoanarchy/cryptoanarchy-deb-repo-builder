#!/bin/bash

# Sets up deb.ln-ask.me repository. Useful for tests in VM.

set -e

test_dir="`dirname "$0"`"

. "$test_dir/common_vars.sh"

sudo cp "$test_data_dir/experimental_apt.list" /etc/apt/sources.list.d/cryptoanarchy-experimental.list
sudo apt-key add < "$test_data_dir/experimental_key.gpg"
sudo apt update
