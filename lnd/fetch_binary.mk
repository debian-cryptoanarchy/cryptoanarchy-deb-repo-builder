LND_ARCH_LONG=linux-$(LND_ARCH)

LND_BIN_ARCHIVE_NAME=lnd-$(LND_ARCH_LONG)-v$(LND_VERSION)-beta.tar.gz
LND_BIN_ARCHIVE=$(BUILD_DIR)/$(LND_BIN_ARCHIVE_NAME)
ROASBEEF_KEY_ID=$(shell echo $(ROASBEEF_FPRINT) | cut -b 25-)
LND_STRATEGY_DEPS=$(BUILD_DIR)/lnd-$(LND_VERSION)/Makefile
LND_DEPS=$(LND_STRATEGY_DEPS)
LND_MANIFEST_FILE=$(BUILD_DIR)/lnd-manifest-v$(LND_VERSION)-beta.txt
LND_MANIFEST_SIG=$(LND_MANIFEST_FILE).sig
LND_FETCH_FILES=$(LND_BIN_ARCHIVE) $(LND_MANIFEST_FILE) $(LND_MANIFEST_SIG) $(BUILD_DIR)/roasbeef.gpg

$(BUILD_DIR)/verify-lnd.stamp: $(LND_BIN_ARCHIVE) $(BUILD_DIR)/lnd-manifest-$(LND_VERSION).ours
	cd $(BUILD_DIR) && sha256sum --check lnd-manifest-$(LND_VERSION).ours
	tar -C $(BUILD_DIR) -xzmf $<
	mv $(BUILD_DIR)/lnd-$(LND_ARCH_LONG)-v$(LND_VERSION)-beta $(BUILD_DIR)/lnd-$(LND_VERSION)
	touch $@

$(BUILD_DIR)/lnd-manifest-$(LND_VERSION).ours: $(LND_MANIFEST_SIG) $(LND_MANIFEST_FILE) $(BUILD_DIR)/roasbeef.gpg
	gpgv --keyring $(BUILD_DIR)/roasbeef.gpg $< $(LND_MANIFEST_FILE)
	grep $(LND_BIN_ARCHIVE_NAME) $(LND_MANIFEST_FILE) > $@

$(BUILD_DIR)/lnd-$(LND_VERSION)/Makefile: $(LND_SOURCE_DIR)assets/bin-makefile $(BUILD_DIR)/verify-lnd.stamp
	cp $< $@

$(BUILD_DIR)/roasbeef.gpg: | $(BUILD_DIR)
	gpg --no-default-keyring --keyring $@ --keyserver hkp://keyserver.ubuntu.com --recv-keys $(ROASBEEF_FPRINT)

$(LND_BIN_ARCHIVE): | $(BUILD_DIR)
	wget -O $@ --no-verbose https://github.com/lightningnetwork/lnd/releases/download/v$(LND_VERSION)-beta/$(LND_BIN_ARCHIVE_NAME)

$(LND_MANIFEST_FILE): | $(BUILD_DIR)
	wget -O $@ --no-verbose https://github.com/lightningnetwork/lnd/releases/download/v$(LND_VERSION)-beta/manifest-v$(LND_VERSION)-beta.txt

$(LND_MANIFEST_SIG): | $(BUILD_DIR)
	wget -O $@ --no-verbose https://github.com/lightningnetwork/lnd/releases/download/v$(LND_VERSION)-beta/manifest-v$(LND_VERSION)-beta.txt.sig
