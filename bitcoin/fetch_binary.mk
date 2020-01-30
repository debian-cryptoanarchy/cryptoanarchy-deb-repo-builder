BITCOIN_ARCH_LONG=$(ARCH)-linux-gnu

BITCOIN_BIN_ARCHIVE_NAME=bitcoin-$(BITCOIN_VERSION)-$(BITCOIN_ARCH_LONG).tar.gz
BITCOIN_BIN_ARCHIVE=$(BUILD_DIR)/$(BITCOIN_BIN_ARCHIVE_NAME)
LAANWJ_KEY_ID=$(shell echo $(LAANWJ_FPRINT) | cut -b 25-)
BITCOIN_STRATEGY_DEPS=$(BUILD_DIR)/bitcoin-$(BITCOIN_VERSION)/Makefile
BITCOIN_DEPS=$(BUILD_DIR)/bitcoin-$(BITCOIN_VERSION) $(BITCOIN_STRATEGY_DEPS)
BITCOIN_FETCH_FILES=$(BITCOIN_BIN_ARCHIVE) $(BUILD_DIR)/bitcoin-SHA256SUMS.asc $(BUILD_DIR)/laanwj.gpg

$(BUILD_DIR)/bitcoin-$(BITCOIN_VERSION): $(BITCOIN_BIN_ARCHIVE) $(BUILD_DIR)/bitcoin-SHA256SUMS
	cd $(BUILD_DIR) && sha256sum --check bitcoin-SHA256SUMS
	tar -C $(BUILD_DIR) -xzmf $<

$(BUILD_DIR)/bitcoin-$(BITCOIN_VERSION)/Makefile: $(BITCOIN_SOURCE_DIR)assets/bin-makefile | $(BUILD_DIR)/bitcoin-$(BITCOIN_VERSION)
	cp $< $@

$(BUILD_DIR)/laanwj.gpg: | $(BUILD_DIR)
	gpg --no-default-keyring --keyring $@ --keyserver hkp://keyserver.ubuntu.com --recv-keys $(LAANWJ_FPRINT)

$(BITCOIN_BIN_ARCHIVE): | $(BUILD_DIR)
	wget -O $@ --no-verbose https://bitcoin.org/bin/bitcoin-core-$(BITCOIN_VERSION)/$(BITCOIN_BIN_ARCHIVE_NAME)

$(BUILD_DIR)/bitcoin-SHA256SUMS.asc: | $(BUILD_DIR)
	wget -O $@ --no-verbose https://bitcoin.org/bin/bitcoin-core-$(BITCOIN_VERSION)/SHA256SUMS.asc

$(BUILD_DIR)/bitcoin-SHA256SUMS: $(BUILD_DIR)/bitcoin-SHA256SUMS.asc $(BUILD_DIR)/laanwj.gpg
	gpgv --keyring $(BUILD_DIR)/laanwj.gpg -o - $< | grep $(BITCOIN_BIN_ARCHIVE_NAME) > $@

clean_bitcoin_strategy_specific:
	rm -rf bitcoin-$(BITCOIN_VERSION) $(BITCOIN_BIN_ARCHIVE) bitcoin-SHA256SUMS bitcoin-SHA256SUMS.asc laanwj.gpg laanwj.gpg~ 

.PHONY: clean_strategy_specific
