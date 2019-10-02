SOURCE_DIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
BITCOIN_SOURCE_DIR=$(SOURCE_DIR)bitcoin/

include common_vars.mk

include bitcoin/vars.mk
include bitcoin-rpc-proxy/vars.mk

all: $(BITCOIN_PACKAGES) $(BITCOIN_RPC_PROXY_PACKAGES)

build-dep:
	sudo apt-get build-dep ./bitcoin/assets/

clean: clean_bitcoin clean_bitcoin_rpc_proxy

include bitcoin/build.mk
include bitcoin-rpc-proxy/build.mk
