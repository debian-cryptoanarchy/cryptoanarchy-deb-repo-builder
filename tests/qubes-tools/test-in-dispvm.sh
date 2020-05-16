#!/bin/bash

tmpdir="`mktemp -d`" || exit 1
script_dir="`dirname "$0"`"
pkg_dir="$1"
shift
source_dir="$1"
shift
source_dir_name="`basename "$source_dir"`"

cp "$pkg_dir"/*.deb "$tmpdir" || exit 1
cp -r "$source_dir" "$tmpdir" || exit 1
cd "$tmpdir" || exit 1

echo 'Copying to DVM' >&2

"$script_dir"/qvm-filter-in-dispvm.sh . gnome-terminal --wait -- "./$source_dir_name/tests/qubes-tools/wait-enter-on-fail.sh" make -C "$source_dir_name" BUILD_DIR=.. "$@"

status=$?

rm -rf "$tmpdir"

exit $status
