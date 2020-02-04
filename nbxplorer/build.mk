NBXPLORER_BUILD_DIR=$(BUILD_DIR)/nbxplorer-$(NBXPLORER_VERSION)
NBXPLORER_DEPS=$(NBXPLORER_BUILD_DIR) $(NBXPLORER_BUILD_DIR)/Makefile
NBXPLORER_ASSETS=
NBXPLORER_REPO_PATCH=cat $(NBXPLORER_SOURCE_DIR)/assets/nbxplorer-control >> $(NBXPLORER_BUILD_DIR)/debian/control
NBXPLORER_FETCH_FILES=$(NBXPLORER_BUILD_DIR)

$(NBXPLORER_BUILD_DIR):
	git clone -b v$(NBXPLORER_VERSION) https://github.com/dgarage/NBXplorer $@

$(NBXPLORER_BUILD_DIR)/debian/nbxplorer.install: | $(BUILD_DIR)/repository.stamp
	echo /usr/lib/NBXplorer > $@
	echo /usr/bin/nbxplorer >> $@

$(NBXPLORER_BUILD_DIR)/Makefile: $(NBXPLORER_SOURCE_DIR)/assets/dotnet-makefile | $(NBXPLORER_BUILD_DIR)
	cp $< $@

$(NBXPLORER_PACKAGES): $(BUILD_DIR)/nbxplorer.stamp
	touch -c $@

$(BUILD_DIR)/nbxplorer.stamp: $(NBXPLORER_DEPS) $(BUILD_DIR)/repository.stamp $(NBXPLORER_BUILD_DIR)/debian/nbxplorer.install $(NBXPLORER_ASSETS)
	cd $(NBXPLORER_BUILD_DIR) && dpkg-buildpackage -a $(DEB_ARCH) $(BUILD_PACKAGE_FLAGS)
	touch $@

clean_nbxplorer:
	rm -rf $(NBXPLORER_PACKAGES) $(NBXPLORER_EXTRA_FILES) $(BUILD_DIR)/nbxplorer.stamp
