# TODO: sign and verify sources

ELECTRS_BUILD_DIR=$(BUILD_DIR)/electrs-$(ELECTRS_VERSION)
ELECTRS_DEPS=$(ELECTRS_BUILD_DIR) $(ELECTRS_BUILD_DIR)/Makefile
ELECTRS_ASSETS=$(ELECTRS_BUILD_DIR)/.cargo $(ELECTRS_BUILD_DIR)/.cargo/config
ELECTRS_FETCH_FILES=$(ELECTRS_BUILD_DIR)

$(ELECTRS_BUILD_DIR):
	git clone https://github.com/romanz/electrs $@

$(ELECTRS_BUILD_DIR)/Makefile: $(SOURCE_DIR)electrs/assets/cargo-makefile | $(ELECTRS_BUILD_DIR)
	cp $< $@

$(ELECTRS_BUILD_DIR)/.cargo: | $(ELECTRS_BUILD_DIR)
	mkdir -p $@

$(ELECTRS_BUILD_DIR)/.cargo/config: $(SOURCE_DIR)common/cross-cargo-conf | $(ELECTRS_BUILD_DIR)/.cargo
	cp $< $@

$(ELECTRS_PACKAGES): $(BUILD_DIR)/electrs.stamp
	touch -c $@

$(BUILD_DIR)/electrs.stamp: $(ELECTRS_DEPS) $(BUILD_DIR)/repository.stamp $(ELECTRS_ASSETS)
	cd $(ELECTRS_BUILD_DIR) && dpkg-buildpackage -a $(DEB_ARCH) $(BUILD_PACKAGE_FLAGS)
	touch $@

clean_electrs:
	rm -rf $(ELECTRS_PACKAGES) $(ELECTRS_EXTRA_FILES) $(BUILD_DIR)/electrs.stamp
