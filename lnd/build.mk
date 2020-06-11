include $(LND_SOURCE_DIR)$(LND_BUILD_STRATEGY).mk

LND_BUILD_DIR=$(BUILD_DIR)/lnd-$(LND_VERSION)

$(LND_BUILD_DIR)/xlncli: $(LND_SOURCE_DIR)/xlncli
	cp $< $@
	chmod +x $@

$(BUILD_DIR)/lnd.stamp: $(BUILD_DIR)/repository.stamp $(LND_BUILD_DIR)/xlncli $(LND_DEPS)
	cd $(LND_BUILD_DIR) && dpkg-buildpackage -a $(DEB_ARCH) $(BUILD_PACKAGE_FLAGS)
	touch $@

$(LND_PACKAGES): $(BUILD_DIR)/lnd.stamp
	touch -c $@

clean_lnd: clean_lnd_strategy_specific
	rm -f $(LND_PACKAGES) $(LND_EXTRA_FILES) $(BUILD_DIR)/lnd.stamp

.PHONY: clean_lnd
