#!/bin/bash

set -ex

BUILD_DIR=/home/user/cadr-build
REPO_DIR=/home/user/cryptoanarchy-deb-repo-builder
sudo apt-get update
sudo chown -R user "$REPO_DIR"
cd "$REPO_DIR"
MKCMD="make SOURCES="$1" BUILD_DIR=${BUILD_DIR}"
$MKCMD build-dep
$MKCMD all
mv "$BUILD_DIR"/*.deb "$REPO_DIR/packages"
