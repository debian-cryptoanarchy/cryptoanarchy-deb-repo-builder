TOR_EXTRAS_BUILD_DIR=$(BUILD_DIR)/tor-extras-$(TOR_EXTRAS_VERSION)
TOR_EXTRAS_REPO_PATCH=cp $(addprefix $(TOR_EXTRAS_SOURCE_DIR)/assets/debian/tor-hs-patch-config., install preinst postinst postrm triggers dirs) $(TOR_EXTRAS_BUILD_DIR)/debian/
TOR_EXTRAS_ASSETS=$(TOR_EXTRAS_BUILD_DIR)/defaults.patch

$(TOR_EXTRAS_BUILD_DIR)/defaults.patch: $(SOURCE_DIR)tor-extras/assets/defaults.patch | $(BUILD_DIR)/repository.stamp
	cp $< $@

$(BUILD_DIR)/tor-extras.stamp: $(BUILD_DIR)/repository.stamp $(TOR_EXTRAS_DEPS) $(TOR_EXTRAS_ASSETS)
	cd $(TOR_EXTRAS_BUILD_DIR) && dpkg-buildpackage -a $(DEB_ARCH) $(BUILD_PACKAGE_FLAGS)
	touch $@

$(TOR_EXTRAS_PACKAGES): $(BUILD_DIR)/tor-extras.stamp
	touch -c $@

clean_tor-extras:
	rm -f $(TOR_EXTRAS_PACKAGES) $(TOR_EXTRAS_EXTRA_FILES) $(BUILD_DIR)/tor-extras.stamp

.PHONY: all clean
