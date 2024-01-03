#!/bin/bash

set -e

cd /home/user/cadr-build

dep="$1"
src="build_rules/$dep.yaml"

function print_deps() {
	echo debcrafter-version
	echo $src
	sss=pkg_specs/`grep '^source_name: ' $src | sed 's/^source_name: //'`.sss
	debcrafter $sss /dev/null --check --print-source-files
}

echo -n packages-cache-key=
print_deps | grep -v '^$' | sort | xargs sha256sum | sha256sum | cut -d ' ' -f 1
