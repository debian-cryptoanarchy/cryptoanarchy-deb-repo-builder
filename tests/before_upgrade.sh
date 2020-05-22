#!/bin/bash

set -e

test_dir="`dirname "$0"`"
pkg_dir="$1"
packages="$2"

. "$test_dir/common.sh"

"$test_dir/setup_deb_ln_ask_me.sh" "--internal-test"

sudo apt install -y $packages
