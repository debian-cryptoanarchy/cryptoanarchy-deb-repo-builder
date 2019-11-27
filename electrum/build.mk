ELECTRUM_BUILD_DIR=$(BUILD_DIR)/electrum-$(ELECTRUM_VERSION)/
ELECTRUM_APPIMAGE_NAME=electrum-$(ELECTRUM_VERSION)-$(ARCH).AppImage
ELECTRUM_APPIMAGE=$(BUILD_DIR)/$(ELECTRUM_APPIMAGE_NAME)
ifeq ($(ARCH),x86_64)
	ELECTRUM_FETCH_FILES=$(ELECTRUM_APPIMAGE) $(ELECTRUM_APPIMAGE).asc $(BUILD_DIR)/thomasv.gpg
	ELECTRUM_DEPS=$(ELECTRUM_BUILD_DIR)
else
	# non-x86_64 isn't supported yet - don't build
	ELECTRUM_FETCH_FILES=
	ELECTRUM_DEPS=
endif
ELECTRUM_REPO_PATCH=cat $(SOURCE_DIR)/electrum/assets/electrum-control >> $(ELECTRUM_BUILD_DIR)/debian/control
ELECTRUM_ASSETS=$(ELECTRUM_BUILD_DIR)/debian/electrum.install $(ELECTRUM_BUILD_DIR)/debian/electrum-trustless-mainnet.install $(ELECTRUM_BUILD_DIR)/electrum-trustless-mainnet $(ELECTRUM_BUILD_DIR)/electrum-trustless-mainnet.desktop
THOMASV_KEY_ID=$(shell echo $(THOMASV_FPRINT) | cut -b 25-)

$(BUILD_DIR)/thomasv.gpg: | $(BUILD_DIR)
	gpg --no-default-keyring --keyring $@ --keyserver hkp://keyserver.ubuntu.com --recv-keys $(THOMASV_FPRINT)

$(ELECTRUM_APPIMAGE): | $(BUILD_DIR)
	wget -O $@ --no-verbose https://download.electrum.org/$(ELECTRUM_VERSION)/$(ELECTRUM_APPIMAGE_NAME)

$(ELECTRUM_APPIMAGE).asc: | $(BUILD_DIR)
	wget -O $@ --no-verbose https://download.electrum.org/$(ELECTRUM_VERSION)/$(ELECTRUM_APPIMAGE_NAME).asc

$(ELECTRUM_BUILD_DIR)/debian/electrum-trustless-mainnet.install: electrum/assets/debian/electrum-trustless-mainnet.install | $(ELECTRUM_BUILD_DIR)
	cp $< $@

$(ELECTRUM_BUILD_DIR)/debian/electrum.install: electrum/assets/debian/electrum.install | $(ELECTRUM_BUILD_DIR)
	cp $< $@

$(ELECTRUM_BUILD_DIR)/electrum-trustless-mainnet: electrum/assets/electrum-trustless-mainnet | $(ELECTRUM_BUILD_DIR)
	cp $< $@

$(ELECTRUM_BUILD_DIR)/electrum-trustless-mainnet.desktop: electrum/assets/electrum-trustless-mainnet.desktop | $(ELECTRUM_BUILD_DIR)
	cp $< $@

$(ELECTRUM_BUILD_DIR)/electrum: $(ELECTRUM_APPIMAGE) | $(ELECTRUM_BUILD_DIR)
	cp $< $@

$(ELECTRUM_BUILD_DIR): $(ELECTRUM_FETCH_FILES)
	gpg --no-default-keyring --keyring $(BUILD_DIR)/thomasv.gpg --trusted-key $(THOMASV_KEY_ID) --verify $(ELECTRUM_APPIMAGE).asc
	mkdir $@

$(BUILD_DIR)/electrum.stamp: $(BUILD_DIR)/repository.stamp $(ELECTRUM_DEPS) $(ELECTRUM_ASSETS) $(ELECTRUM_BUILD_DIR)/electrum
	cd $(ELECTRUM_BUILD_DIR) && dpkg-buildpackage -a $(DEB_ARCH) $(BUILD_PACKAGE_FLAGS)
	touch $@

$(ELECTRUM_PACKAGES): $(BUILD_DIR)/electrum.stamp
	touch -c $@

clean_electrum:
	rm -f $(ELECTRUM_PACKAGES) $(BUILD_DIR)/electrum.stamp

.PHONY: clean_electrum
