MAINTAINER="Martin Habostiak <martin.habovstiak@gmail.com>"

SOURCE_DIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
BITCOIN_SOURCE_DIR=$(SOURCE_DIR)bitcoin/
# Forgetting to type this resulted in lot of time wasted.
BUILD_PACKAGE_FLAGS=-nc --no-sign
HAS_QVM_RUN_VM=$(shell which qvm-run-vm 2>&1 >/dev/null; echo $$?)
TEST_SPLIT_STRATEGY=none
TEST_ALL_PACKAGES=bitcoind bitcoin-mainnet bitcoin-regtest bitcoin-pruned-mainnet bitcoin-fullchain-mainnet bitcoin-fullchain-regtest bitcoin-txindex-mainnet bitcoin-zmq-mainnet bitcoin-zmq-regtest bitcoin-rpc-proxy bitcoin-rpc-proxy-mainnet bitcoin-rpc-proxy-regtest bitcoin-timechain-mainnet electrs electrs-mainnet electrs-regtest btcpayserver btcpayserver-system-mainnet btcpayserver-system-regtest btcpayserver-system-selfhost-mainnet lnd lnd-system-mainnet lnd-system-regtest lnd-unlocker-system-mainnet lnd-unlocker-system-mainnet ridetheln ridetheln-system ridetheln-system-selfhost ridetheln-lnd-system-mainnet ridetheln-lnd-system-regtest selfhost selfhost-nginx selfhost-onion selfhost-clearnet selfhost-clearnet-certbot tor-hs-patch-config thunderhub thunderhub-system-mainnet thunderhub-system-regtest thunderhub-system-selfhost-mainnet thunderhub-system-selfhost-regtest btc-rpc-explorer-mainnet btc-rpc-explorer-regtest lndconnect
TEST_MULTI_PACKAGE=lnd-regtest
TEST_ALL_PACKAGES_NON_CONFLICT=$(filter-out bitcoin-pruned bitcoin-fullchain,$(TEST_ALL_PACKAGES))
SPLIT_STRATEGY=none
export DPKG_DEBUG_LEVEL

ifeq ($(HAS_QVM_RUN_VM),0)
	TEST_DEPS=test-in-qubes-dvm
	TEST_STRATEGY=in-qubes-dvm
else
	TEST_DEPS=test-here
	TEST_STRATEGY=here
endif

ifeq ($(SPLIT_STRATEGY),none)
	UPGRADE_DEPS=test-here-all-basic
else
	UPGRADE_DEPS=
endif

.DELETE_ON_ERROR:

SOURCES=bitcoin bitcoin-rpc-proxy electrs electrum lnd nbxplorer btcpayserver ridetheln selfhost tor-extras thunderhub btc-rpc-explorer lndconnect lnpbp-testkit

include common_vars.mk

all: $(addsuffix .mk,$(addprefix $(BUILD_DIR)/vars-,$(SOURCES)) $(addprefix $(BUILD_DIR)/build-,$(SOURCES)))

clean:

include common_rules.mk

build-dep:
	sudo apt-get build-dep $(realpath $(BITCOIN_DIR) $(BITCOIN_RPC_PROXY_BUILD_DIR) $(ELECTRS_BUILD_DIR) $(ELECTRUM_BUILD_DIR) $(TOR_EXTRAS_BUILD_DIR) $(LND_BUILD_DIR) $(NBXPLORER_BUILD_DIR) $(BTCPAYSERVER_BUILD_DIR) $(SELFHOST_BUILD_DIR) $(RIDETHELN_BUILD_DIR) $(LNPBP_TESTKIT_BUILD_DIR))

test: $(TEST_DEPS)

test-here: test-here-all-basic test-here-all-nonconfict-upgrade

test-in-qubes-dvm: test-split-$(SPLIT_STRATEGY) $(addprefix test-in-qubes-dvm-multi-package-,$(TEST_MULTI_PACKAGE))

test-split-none:
	$(SOURCE_DIR)/tests/qubes-tools/test-in-dispvm.sh "$(BUILD_DIR)" "$(SOURCE_DIR)" "TEST_ALL_PACKAGES=$(TEST_ALL_PACKAGES)" "DPKG_DEBUG_LEVEL=$(DPKG_DEBUG_LEVEL)" test-here

test-split-upgrade: test-in-qubes-dvm-all-basic $(addprefix test-in-qubes-dvm-upgrade-,$(TEST_ALL_PACKAGES))

test-split-all: $(addprefix test-in-qubes-dvm-basic-,$(TEST_ALL_PACKAGES)) $(addprefix test-in-qubes-dvm-upgrade-,$(TEST_ALL_PACKAGES))

test-package-%: test-$(TEST_STRATEGY)-basic-%

test-in-qubes-dvm-multi-package-%: tests/multi-package/%.sh
	$(SOURCE_DIR)/tests/qubes-tools/test-in-dispvm.sh "$(BUILD_DIR)" "$(SOURCE_DIR)" "TEST_MULTI_PACKAGE=$(TEST_MULTI_PACKAGE)" "DPKG_DEBUG_LEVEL=$(DPKG_DEBUG_LEVEL)" "test-here-multi-package-$*"

test-here-multi-package-%: tests/multi-package/%.sh
	$(SOURCE_DIR)/tests/prepare_machine.sh "$(BUILD_DIR)"
	$<

test-here-all-basic: $(addprefix test-here-basic-,$(TEST_ALL_PACKAGES))
	echo "Basic test done" >&2
	bash -c '. $(SOURCE_DIR)/tests/common.sh && sudo mv "$$apt_repo_dir" "$$apt_repo_dir.tmp"'

test-here-basic-%: test-here-prepare-machine
	$(SOURCE_DIR)/tests/package_clean_install.sh "$(BUILD_DIR)" "$*"

test-here-upgrade-%: | $(UPGRADE_DEPS)
	$(SOURCE_DIR)/tests/before_upgrade.sh "$(BUILD_DIR)" "$*"
	$(SOURCE_DIR)/tests/prepare_machine.sh "$(BUILD_DIR)"
	$(SOURCE_DIR)/tests/upgrade_package.sh "$(BUILD_DIR)" "$*"

test-here-prepare-all-nonconfict-upgrade: | $(UPGRADE_DEPS)
	$(SOURCE_DIR)/tests/before_upgrade.sh "$(BUILD_DIR)" "$(TEST_ALL_PACKAGES_NON_CONFLICT)"
	$(SOURCE_DIR)/tests/prepare_machine.sh "$(BUILD_DIR)"

test-here-single-nonconfict-upgrade-%: test-here-prepare-all-nonconfict-upgrade | $(UPGRADE_DEPS)
	$(SOURCE_DIR)/tests/upgrade_package.sh "$(BUILD_DIR)" "$*"

test-here-all-nonconfict-upgrade: $(addprefix test-here-single-nonconfict-upgrade-,$(TEST_ALL_PACKAGES_NON_CONFLICT)) | $(UPGRADE_DEPS)

test-here-prepare-machine:
	$(SOURCE_DIR)/tests/prepare_machine.sh "$(BUILD_DIR)"

test-in-qubes-dvm-all-basic:
	$(SOURCE_DIR)/tests/qubes-tools/test-in-dispvm.sh "$(BUILD_DIR)" "$(SOURCE_DIR)" "TEST_ALL_PACKAGES=$(TEST_ALL_PACKAGES)" "DPKG_DEBUG_LEVEL=$(DPKG_DEBUG_LEVEL)" test-here-all-basic

test-in-qubes-dvm-basic-%:
	$(SOURCE_DIR)/tests/qubes-tools/test-in-dispvm.sh "$(BUILD_DIR)" "$(SOURCE_DIR)" "TEST_ALL_PACKAGES=$(TEST_ALL_PACKAGES)" "DPKG_DEBUG_LEVEL=$(DPKG_DEBUG_LEVEL)" "test-here-basic-$*"

test-in-qubes-dvm-upgrade-%:
	$(SOURCE_DIR)/tests/qubes-tools/test-in-dispvm.sh "$(BUILD_DIR)" "$(SOURCE_DIR)" SPLIT_STRATEGY=upgrade "TEST_ALL_PACKAGES=$(TEST_ALL_PACKAGES)" "DPKG_DEBUG_LEVEL=$(DPKG_DEBUG_LEVEL)" "test-here-upgrade-$*"
