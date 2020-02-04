SOURCE_DIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
BITCOIN_SOURCE_DIR=$(SOURCE_DIR)bitcoin/
# Forgetting to type this resulted in lot of time wasted.
BUILD_PACKAGE_FLAGS=-nc --no-sign

.DELETE_ON_ERROR:

include common_vars.mk

include bitcoin/vars.mk
include bitcoin-rpc-proxy/vars.mk
include electrs/vars.mk
include electrum/vars.mk
include tor-extras/vars.mk
include lnd/vars.mk
include nbxplorer/vars.mk

all: $(BITCOIN_PACKAGES) $(BITCOIN_RPC_PROXY_PACKAGES) $(ELECTRS_PACKAGES) $(ELECTRUM_PACKAGES) $(TOR_EXTRAS_PACKAGES) $(LND_PACKAGES) $(NBXPLORER_PACKAGES)

clean: clean_bitcoin clean_bitcoin_rpc_proxy clean_electrs clean_electrum clean_tor_extras clean_lnd

include common_rules.mk
include bitcoin/build.mk
include bitcoin-rpc-proxy/build.mk
include electrs/build.mk
include electrum/build.mk
include tor-extras/build.mk
include lnd/build.mk
include nbxplorer/build.mk

$(BUILD_DIR)/repository.stamp: pkg_specs/packages.srs $(wildcard pkg_specs/*.sps) $(shell which gen_deb_repository) | $(BITCOIN_DEPS) $(BITCOIN_RPC_PROXY_DEPS) $(ELECTRS_DEPS) $(ELECTRUM_DEPS) $(TOR_EXTRAS_DEPS) $(LND_DEPS)
	gen_deb_repository $< $(BUILD_DIR)
	$(BITCOIN_REPO_PATCH)
	$(BITCOIN_RPC_PROXY_REPO_PATCH)
	$(ELECTRS_REPO_PATCH)
	$(ELECTRUM_REPO_PATCH)
	$(TOR_EXTRAS_REPO_PATCH)
	$(LND_REPO_PATCH)
	$(NBXPLORER_REPO_PATCH)
	touch $@

fetch: $(BITCOIN_FETCH_FILES) $(BITCOIN_RPC_PROXY_FETCH_FILES) $(ELECTRS_FETCH_FILES) $(ELECTRUM_FETCH_FILES) $(TOR_EXTRAS_FILES) $(LND_FETCH_FILES) $(NBXPLORER_FETCH_FILES)

build-dep: $(BUILD_DIR)/repository.stamp
	sudo apt-get build-dep $(realpath $(BITCOIN_DIR) $(BITCOIN_RPC_PROXY_BUILD_DIR) $(ELECTRS_BUILD_DIR) $(ELECTRUM_BUILD_DIR) $(TOR_EXTRAS_BUILD_DIR) $(LND_BUILD_DIR) $(NBXPLORER_BUILD_DIR))
