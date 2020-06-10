RIDETHELN_BUILD_DIR=$(BUILD_DIR)/ridetheln-$(RIDETHELN_VERSION)
RIDETHELN_DEPS=$(RIDETHELN_BUILD_DIR) $(RIDETHELN_BUILD_DIR)/Makefile
RIDETHELN_ASSETS=$(RIDETHELN_BUILD_DIR)/ridetheln $(RIDETHELN_BUILD_DIR)/alloc_index.sh $(RIDETHELN_BUILD_DIR)/update_config.sh
RIDETHELN_FETCH_FILES=$(RIDETHELN_BUILD_DIR)

$(RIDETHELN_BUILD_DIR):
	git clone -b v$(RIDETHELN_VERSION) https://github.com/Ride-The-Lightning/RTL $@
	rm -rf '$@/product management'
	cd $@ && npm install --production

$(RIDETHELN_BUILD_DIR)/debian/ridetheln.install: | $(BUILD_DIR)/repository.stamp $(BUILD_DIR)/repository.stamp
	echo /usr/share/ridetheln > $@
	echo /usr/bin/ridetheln >> $@

$(RIDETHELN_BUILD_DIR)/Makefile: $(RIDETHELN_SOURCE_DIR)/assets/npm-makefile | $(RIDETHELN_BUILD_DIR)
	cp $< $@

$(RIDETHELN_BUILD_DIR)/alloc_index.sh: $(RIDETHELN_SOURCE_DIR)/alloc_index.sh
	cp $< $@
	chmod 755 $@

$(RIDETHELN_BUILD_DIR)/update_config.sh: $(RIDETHELN_SOURCE_DIR)/update_config.sh
	cp $< $@
	chmod 755 $@

$(RIDETHELN_BUILD_DIR)/ridetheln: $(RIDETHELN_SOURCE_DIR)/assets/ridetheln
	cp $< $@
	chmod 755 $@

$(RIDETHELN_PACKAGES): $(BUILD_DIR)/ridetheln.stamp
	touch -c $@

$(BUILD_DIR)/ridetheln.stamp: $(RIDETHELN_DEPS) $(BUILD_DIR)/repository.stamp $(RIDETHELN_BUILD_DIR)/debian/ridetheln.install $(RIDETHELN_ASSETS)
	cd $(RIDETHELN_BUILD_DIR) && dpkg-buildpackage -a $(DEB_ARCH) $(BUILD_PACKAGE_FLAGS)
	touch $@

clean_ridetheln:
	rm -rf $(RIDETHELN_PACKAGES) $(RIDETHELN_EXTRA_FILES) $(BUILD_DIR)/ridetheln.stamp
