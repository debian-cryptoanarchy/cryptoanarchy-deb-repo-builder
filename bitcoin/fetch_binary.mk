BITCOIN_ARCH_LONG=$(ARCH)-linux-gnu

BITCOIN_ARCHIVE_NAME=bitcoin-$(BITCOIN_VERSION)-$(BITCOIN_ARCH_LONG).tar.gz
LAANWJ_KEY_ID=$(shell echo $(LAANWJ_FPRINT) | cut -b 25-)
BITCOIN_STRATEGY_DEPS=bitcoin-$(BITCOIN_VERSION)/Makefile

bitcoin-$(BITCOIN_VERSION): $(BITCOIN_ARCHIVE_NAME) SHA256SUMS
	sha256sum --check SHA256SUMS
	tar -xzmf $<

bitcoin-$(BITCOIN_VERSION)/Makefile: $(BITCOIN_SOURCE_DIR)assets/bin-makefile bitcoin-$(BITCOIN_VERSION)
	cp $< $@

laanwj.gpg:
	gpg --no-default-keyring --keyring ./$@ --recv-keys $(LAANWJ_FPRINT)

bitcoin-$(BITCOIN_VERSION)-$(BITCOIN_ARCH_LONG).tar.gz:
	wget --no-verbose https://bitcoin.org/bin/bitcoin-core-$(BITCOIN_VERSION)/$(BITCOIN_ARCHIVE_NAME)

SHA256SUMS.asc:
	wget --no-verbose https://bitcoin.org/bin/bitcoin-core-$(BITCOIN_VERSION)/SHA256SUMS.asc

SHA256SUMS: SHA256SUMS.asc laanwj.gpg
	gpg --no-default-keyring --keyring ./laanwj.gpg --trusted-key $(LAANWJ_KEY_ID) --verify $<
	gpg --no-default-keyring --keyring ./laanwj.gpg --trusted-key $(LAANWJ_KEY_ID) -d $< | grep $(BITCOIN_ARCHIVE_NAME) > $@

clean_bitcoin_strategy_specific:
	rm -rf bitcoin-$(BITCOIN_VERSION) $(BITCOIN_ARCHIVE_NAME) SHA256SUMS SHA256SUMS.asc laanwj.gpg laanwj.gpg~ 

.PHONY: clean_strategy_specific
