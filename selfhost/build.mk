SELFHOST_BUILD_DIR=$(BUILD_DIR)/selfhost-$(SELFHOST_VERSION)
SELFHOST_DEPS=$(SELFHOST_BUILD_DIR)
SELFHOST_ASSETS=$(SELFHOST_BUILD_DIR)/nginx $(SELFHOST_BUILD_DIR)/certbot $(SELFHOST_BUILD_DIR)/onion
SELFHOST_FETCH_FILES=

$(SELFHOST_BUILD_DIR):
	mkdir -p $@

$(SELFHOST_BUILD_DIR)/nginx: $(SELFHOST_SOURCE_DIR)/nginx $(wildcard $(SELFHOST_SOURCE_DIR)/nginx/*)
	cp -rT $< $@
	touch $@

$(SELFHOST_BUILD_DIR)/certbot: $(SELFHOST_SOURCE_DIR)/certbot $(wildcard $(SELFHOST_SOURCE_DIR)/certbot/*)
	cp -rT $< $@
	touch $@

$(SELFHOST_BUILD_DIR)/onion: $(SELFHOST_SOURCE_DIR)/onion $(wildcard $(SELFHOST_SOURCE_DIR)/onion/*)
	cp -rT $< $@
	touch $@

$(SELFHOST_PACKAGES): $(BUILD_DIR)/selfhost.stamp
	touch -c $@

$(BUILD_DIR)/selfhost.stamp: $(SELFHOST_DEPS) $(BUILD_DIR)/repository.stamp $(SELFHOST_ASSETS)
	cd $(SELFHOST_BUILD_DIR) && dpkg-buildpackage -a $(DEB_ARCH) $(BUILD_PACKAGE_FLAGS)
	touch $@

clean_selfhost:
	rm -f $(SELFHOST_PACKAGES) $(SELFHOST_EXTRA_FILES) $(BUILD_DIR)/selfhost.stamp
