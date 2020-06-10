BTCPAYSERVER_BUILD_DIR=$(BUILD_DIR)/btcpayserver-$(BTCPAYSERVER_VERSION)
BTCPAYSERVER_DEPS=$(BTCPAYSERVER_BUILD_DIR) $(BTCPAYSERVER_BUILD_DIR)/Makefile
BTCPAYSERVER_ASSETS=
BTCPAYSERVER_FETCH_FILES=$(BTCPAYSERVER_BUILD_DIR)

$(BTCPAYSERVER_BUILD_DIR):
	git clone -b v$(BTCPAYSERVER_VERSION) https://github.com/btcpayserver/btcpayserver $@

$(BTCPAYSERVER_BUILD_DIR)/debian/btcpayserver.install: | $(BUILD_DIR)/repository.stamp
	echo /usr/lib/BTCPayServer > $@
	echo /usr/bin/btcpayserver >> $@

$(BTCPAYSERVER_BUILD_DIR)/Makefile: $(BTCPAYSERVER_SOURCE_DIR)/assets/dotnet-makefile | $(BTCPAYSERVER_BUILD_DIR)
	cp $< $@

$(BTCPAYSERVER_PACKAGES): $(BUILD_DIR)/btcpayserver.stamp
	touch -c $@

$(BUILD_DIR)/btcpayserver.stamp: $(BTCPAYSERVER_DEPS) $(BUILD_DIR)/repository.stamp $(BTCPAYSERVER_BUILD_DIR)/debian/btcpayserver.install $(BTCPAYSERVER_ASSETS)
	cd $(BTCPAYSERVER_BUILD_DIR) && dpkg-buildpackage -a $(DEB_ARCH) $(BUILD_PACKAGE_FLAGS)
	touch $@

clean_btcpayserver:
	rm -rf $(BTCPAYSERVER_PACKAGES) $(BTCPAYSERVER_EXTRA_FILES) $(BUILD_DIR)/btcpayserver.stamp
