SOURCE_DIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
BITCOIN_SOURCE_DIR=$(SOURCE_DIR)bitcoin/

include common_vars.mk

include bitcoin/vars.mk
include bitcoin-rpc-proxy/vars.mk

all: $(BITCOIN_PACKAGES) $(BITCOIN_RPC_PROXY_PACKAGES)

clean: clean_bitcoin clean_bitcoin_rpc_proxy

include common_rules.mk
include bitcoin/build.mk
include bitcoin-rpc-proxy/build.mk

$(BUILD_DIR)/repository.stamp: pkg_specs/packages.srs $(wildcard pkg_specs/*.sps) $(shell which gen_deb_repository) | $(BITCOIN_DEPS) $(BITCOIN_RPC_PROXY_DEPS) $(ELECTRS_DEPS)
	gen_deb_repository $< $(BUILD_DIR)
	$(BITCOIN_REPO_PATCH)
	$(BITCOIN_RPC_PROXY_REPO_PATCH)
	touch $@

fetch: $(BITCOIN_FETCH_FILES) $(BITCOIN_RPC_PROXY_FETCH_FILES) $(ELECTRS_FETCH_FILES)

build-dep: $(BUILD_DIR)/repository.stamp
	sudo apt-get build-dep $(realpath $(BUILD_DIR)/bitcoin-$(BITCOIN_VERSION))
