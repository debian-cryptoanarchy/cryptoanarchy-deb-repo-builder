#!/bin/sh

case "$DEB_ARCH" in
	amd64)
		toolchain_arch=x86_64-linux-gnu
		target_arch=x64
		;;
	armhf)
		toolchain_arch=arm-linux-gnueabihf
		target_arch=arm
		;;
	arm64)
		toolchain_arch=aarch64-linux-gnu
		target_arch=arm64
		;;
	*)
		echo "Unknown architecture $DEB_ARCH"
		exit 1
		;;
esac

CC_target=$toolchain_arch-gcc CXX_target=$toolchain_arch-g++ CC_host=gcc CXX_host=g++ npm_config_arch="$target_arch" npm install --build-from-source
