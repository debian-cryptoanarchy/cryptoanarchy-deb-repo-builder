SOURCE_DIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
BITCOIN_SOURCE_DIR=$(SOURCE_DIR)bitcoin/

include common_vars.mk

include bitcoin/vars.mk
include bitcoin-rpc-proxy/vars.mk

all: service-deb-utils0_0.1-1_all.deb $(BITCOIN_PACKAGES) $(BITCOIN_RPC_PROXY_PACKAGES)

build-dep:
	sudo apt-get build-dep ./bitcoin/assets/

clean: clean_service_deb_utils clean_bitcoin clean_bitcoin_rpc_proxy

include bitcoin/build.mk
include bitcoin-rpc-proxy/build.mk

service-deb-utils0_0.1-1_all.deb: service-deb-utils/usr/share/service-deb-utils0/postinst
	cd service-deb-utils; dpkg-buildpackage $(BUILD_PACKAGE_FLAGS)

clean_service_deb_utils:
	rm -f service-deb-utils0_0.1-1_all.deb  service-deb-utils0_0.1-1_amd64.buildinfo  service-deb-utils0_0.1-1_amd64.changes  service-deb-utils0_0.1-1.dsc  service-deb-utils0_0.1-1.tar.gz
