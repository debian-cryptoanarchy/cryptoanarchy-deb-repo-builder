# TODO: sign and verify sources

BITCOIN_RPC_PROXY_BUILD_DIR=$(BUILD_DIR)/btc-rpc-proxy-$(BTC_RPC_PROXY_VERSION)
BITCOIN_RPC_PROXY_DEPS=$(BITCOIN_RPC_PROXY_BUILD_DIR) $(BITCOIN_RPC_PROXY_BUILD_DIR)/Makefile
BITCOIN_RPC_PROXY_REPO_PATCH=cat $(SOURCE_DIR)/bitcoin-rpc-proxy/assets/bitcoin-rpc-proxy-control >> $(BITCOIN_RPC_PROXY_BUILD_DIR)/debian/control
BITCOIN_RPC_PROXY_FETCH_FILES=$(BITCOIN_RPC_PROXY_BUILD_DIR)

$(BITCOIN_RPC_PROXY_BUILD_DIR):
	git clone https://github.com/Kixunil/btc-rpc-proxy $@

$(BITCOIN_RPC_PROXY_BUILD_DIR)/debian/bitcoin-rpc-proxy.manpages: | $(BUILD_DIR)/repository.stamp
	echo 'target/man/btc_rpc_proxy.1' > $@

$(BITCOIN_RPC_PROXY_BUILD_DIR)/debian/bitcoin-rpc-proxy.install: | $(BUILD_DIR)/repository.stamp
	echo 'target/release/btc_rpc_proxy usr/bin' > $@

$(BITCOIN_RPC_PROXY_BUILD_DIR)/Makefile: $(SOURCE_DIR)bitcoin-rpc-proxy/assets/cargo-makefile | $(BITCOIN_RPC_PROXY_BUILD_DIR)
	cp $< $@

$(BITCOIN_RPC_PROXY_PACKAGES): $(BUILD_DIR)/bitcoin-rpc-proxy.stamp
	touch $@

$(BUILD_DIR)/bitcoin-rpc-proxy.stamp: $(BITCOIN_RPC_PROXY_DEPS) $(BUILD_DIR)/repository.stamp $(BITCOIN_RPC_PROXY_BUILD_DIR)/debian/bitcoin-rpc-proxy.install $(BITCOIN_RPC_PROXY_BUILD_DIR)/debian/bitcoin-rpc-proxy.manpages
	cd $(BITCOIN_RPC_PROXY_BUILD_DIR) && dpkg-buildpackage $(BUILD_PACKAGE_FLAGS)
	touch $@

clean_bitcoin_rpc_proxy:
	rm -rf $(BITCOIN_RPC_PROXY_PACKAGES) $(BITCOIN_RPC_PROXY_EXTRA_FILES) $(BUILD_DIR)/bitcoin-rpc-proxy.stamp
