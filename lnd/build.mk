include $(LND_SOURCE_DIR)$(LND_BUILD_STRATEGY).mk

LND_BUILD_DIR=$(BUILD_DIR)/lnd-$(LND_VERSION)

$(LND_BUILD_DIR)/debian/lnd.install: $(LND_SOURCE_DIR)/assets/debian/lnd.install $(BUILD_DIR)/repository.stamp
	cp $< $@

$(LND_BUILD_DIR)/debian/lncli.install: $(LND_SOURCE_DIR)/assets/debian/lncli.install $(BUILD_DIR)/repository.stamp
	cp $< $@

$(LND_BUILD_DIR)/debian/lncli.postinst: $(LND_SOURCE_DIR)/assets/debian/lncli.postinst $(BUILD_DIR)/repository.stamp
	cp $< $@

$(LND_BUILD_DIR)/debian/lncli.prerm: $(LND_SOURCE_DIR)/assets/debian/lncli.prerm $(BUILD_DIR)/repository.stamp
	cp $< $@

$(LND_BUILD_DIR)/xlncli: $(LND_SOURCE_DIR)/xlncli
	cp $< $@
	chmod +x $@

$(BUILD_DIR)/lnd.stamp: $(BUILD_DIR)/repository.stamp $(LND_BUILD_DIR)/xlncli $(LND_DEPS) $(addprefix $(LND_BUILD_DIR)/debian/,lnd.install lncli.install lncli.postinst lncli.prerm)
	cd $(LND_BUILD_DIR) && dpkg-buildpackage -a $(DEB_ARCH) $(BUILD_PACKAGE_FLAGS)
	touch $@

$(LND_PACKAGES): $(BUILD_DIR)/lnd.stamp
	touch -c $@

clean_lnd: clean_lnd_strategy_specific
	rm -f $(LND_PACKAGES) $(LND_EXTRA_FILES) $(BUILD_DIR)/lnd.stamp

.PHONY: clean_lnd
