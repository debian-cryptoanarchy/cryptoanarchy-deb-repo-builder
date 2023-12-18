#!/bin/bash

set -ex

BUILD_DIR=/home/user/cadr-build
sudo apt-get update
sudo chown -R user $BUILD_DIR
cd $BUILD_DIR
MKCMD="make SOURCES="$1" BUILD_DIR=${BUILD_DIR}/build"
$MKCMD build-dep
$MKCMD all
