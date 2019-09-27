include $(BITCOIN_SOURCE_DIR)$(BUILD_STRATEGY).mk

BITCOIN_CONFIG_FILES=$(addprefix bitcoin-$(BITCOIN_VERSION)/config/,zmq pruned/chain_mode fullchain/chain_mode txindex/chain_mode)

bitcoin.stamp: bitcoin-$(BITCOIN_VERSION) $(BITCOIN_CONTROL_FILES_DST) $(BITCOIN_CONFIG_FILES_DST) $(BITCOIN_STRATEGY_DEPS)
	cd bitcoin-$(BITCOIN_VERSION); dpkg-buildpackage $(BUILD_PACKAGE_FLAGS)
	touch bitcoin.stamp

$(BITCOIN_PACKAGES): bitcoin.stamp

bitcoin-$(BITCOIN_VERSION)/debian: bitcoin-$(BITCOIN_VERSION)
	mkdir -p $@

bitcoin-$(BITCOIN_VERSION)/debian/%: $(BITCOIN_SOURCE_DIR)assets/debian/% | bitcoin-$(BITCOIN_VERSION)/debian
	cp -r $< $@

bitcoin-$(BITCOIN_VERSION)/config: bitcoin-$(BITCOIN_VERSION)
	mkdir -p $@

bitcoin-$(BITCOIN_VERSION)/config/%: $(BITCOIN_SOURCE_DIR)assets/config/% | bitcoin-$(BITCOIN_VERSION)/config
	cp -r $< $@

clean_bitcoin: clean_bitcoin_strategy_specific
	rm -f $(BITCOIN_PACKAGES) $(BITCOIN_EXTRA_FILES) bitcoin.stamp

.PHONY: all clean
