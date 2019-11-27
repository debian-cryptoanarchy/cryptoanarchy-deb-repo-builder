include $(BITCOIN_SOURCE_DIR)$(BUILD_STRATEGY).mk

BITCOIN_DIR=$(BUILD_DIR)/bitcoin-$(BITCOIN_VERSION)/
BITCOIN_CONFIG_FILES=$(addprefix $(BITCOIN_DIR)config/,zmq pruned/chain_mode fullchain/chain_mode txindex/chain_mode)
BITCOIN_REPO_PATCH=cat $(BITCOIN_SOURCE_DIR)/assets/bitcoind-control >> $(BITCOIN_DIR)debian/control && cp $(BITCOIN_SOURCE_DIR)/assets/debian/bitcoind.install $(BITCOIN_DIR)debian/

$(BUILD_DIR)/bitcoin.stamp: $(BUILD_DIR)/repository.stamp $(BITCOIN_DEPS)
	cd $(BITCOIN_DIR) && dpkg-buildpackage -a $(DEB_ARCH) $(BUILD_PACKAGE_FLAGS)
	touch $@

$(BITCOIN_PACKAGES): $(BUILD_DIR)/bitcoin.stamp
	touch -c $@

clean_bitcoin: clean_bitcoin_strategy_specific
	rm -f $(BITCOIN_PACKAGES) $(BITCOIN_EXTRA_FILES) $(BUILD_DIR)/bitcoin.stamp

.PHONY: all clean
