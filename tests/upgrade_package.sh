#!/bin/bash

set -e

test_dir="`dirname "$0"`"
pkg_dir="$1"
package="$2"

. "$test_dir/common.sh"

package_type="${package_type["$package"]}"

echo "Upgrading package $package" >&2
sudo apt-get install -y "$package"
echo "Checking package $package" >&2
check "$package" "$package_type" "after_upgrade"
