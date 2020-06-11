include $(BITCOIN_SOURCE_DIR)$(BITCOIN_BUILD_STRATEGY).mk

BITCOIN_DIR=$(BUILD_DIR)/bitcoin-$(BITCOIN_VERSION)/
BITCOIN_CONFIG_FILES=$(addprefix $(BITCOIN_DIR)config/,zmq pruned/chain_mode fullchain/chain_mode txindex/chain_mode)

$(BUILD_DIR)/bitcoin.stamp: $(BUILD_DIR)/repository.stamp $(BITCOIN_DEPS)
	cd $(BITCOIN_DIR) && dpkg-buildpackage -a $(DEB_ARCH) $(BUILD_PACKAGE_FLAGS)
	touch $@

$(BITCOIN_PACKAGES): $(BUILD_DIR)/bitcoin.stamp
	touch -c $@

clean_bitcoin: clean_bitcoin_strategy_specific
	rm -f $(BITCOIN_PACKAGES) $(BITCOIN_EXTRA_FILES) $(BUILD_DIR)/bitcoin.stamp

.PHONY: all clean
