#!/bin/bash

tmpdir="`mktemp -d`" || exit 1

cp "$1"/*.deb "$tmpdir" || exit 1
cp -r "$2" "$tmpdir" || exit 1
cd "$tmpdir" || exit 1

echo 'Copying to DVM' >&2

`dirname "$0"`/qvm-filter-in-dispvm.sh . gnome-terminal --wait -- "./`basename "$2"`/tests/qubes-tools/wait-enter-on-fail.sh" make -C "`basename "$2"`" BUILD_DIR=.. $3

status=$?

rm -rf "$tmpdir"

exit $status
