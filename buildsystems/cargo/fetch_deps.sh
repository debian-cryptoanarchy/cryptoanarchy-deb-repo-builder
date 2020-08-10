#!/bin/bash

set -e

mkdir -p .cargo
cp "`dirname "$0"`/../../common/cross-cargo-conf" ".cargo/config"
cargo fetch --locked
