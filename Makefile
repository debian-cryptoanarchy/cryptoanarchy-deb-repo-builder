SOURCE_DIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
BITCOIN_SOURCE_DIR=$(SOURCE_DIR)bitcoin/
# Forgetting to type this resulted in lot of time wasted.
BUILD_PACKAGE_FLAGS=-nc --no-sign
HAS_QVM_RUN_VM=$(shell which qvm-run-vm 2>&1 >/dev/null; echo $$?)
TEST_SPLIT_STRATEGY=none
TEST_ALL_PACKAGES=bitcoind bitcoin-mainnet bitcoin-regtest bitcoin-pruned-mainnet bitcoin-fullchain-mainnet bitcoin-fullchain-regtest bitcoin-txindex-mainnet bitcoin-zmq-mainnet bitcoin-zmq-regtest bitcoin-rpc-proxy bitcoin-rpc-proxy-mainnet bitcoin-rpc-proxy-regtest bitcoin-timechain-mainnet electrs electrs-mainnet electrs-regtest btcpayserver btcpayserver-system-mainnet btcpayserver-system-regtest btcpayserver-system-selfhost-mainnet lnd lnd-system-mainnet lnd-system-regtest ridetheln ridetheln-system ridetheln-system-selfhost ridetheln-lnd-system-mainnet ridetheln-lnd-system-regtest selfhost selfhost-nginx selfhost-onion selfhost-clearnet selfhost-clearnet-certbot tor-hs-patch-config
TEST_ALL_PACKAGES_NON_CONFLICT=$(filter-out bitcoin-pruned bitcoin-fullchain,$(TEST_ALL_PACKAGES))
SPLIT_STRATEGY=none

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

include common_vars.mk

include bitcoin/vars.mk
include bitcoin-rpc-proxy/vars.mk
include electrs/vars.mk
include electrum/vars.mk
include tor-extras/vars.mk
include lnd/vars.mk
include nbxplorer/vars.mk
include btcpayserver/vars.mk
include selfhost/vars.mk
include ridetheln/vars.mk

all: $(BITCOIN_PACKAGES) $(BITCOIN_RPC_PROXY_PACKAGES) $(ELECTRS_PACKAGES) $(ELECTRUM_PACKAGES) $(TOR_EXTRAS_PACKAGES) $(LND_PACKAGES) $(NBXPLORER_PACKAGES) $(BTCPAYSERVER_PACKAGES) $(SELFHOST_PACKAGES) $(RIDETHELN_PACKAGES)

clean: clean_bitcoin clean_bitcoin_rpc_proxy clean_electrs clean_electrum clean_tor_extras clean_lnd clean_selfhost clean_ridetheln

include common_rules.mk
include bitcoin/build.mk
include bitcoin-rpc-proxy/build.mk
include electrs/build.mk
include electrum/build.mk
include tor-extras/build.mk
include lnd/build.mk
include nbxplorer/build.mk
include btcpayserver/build.mk
include selfhost/build.mk
include ridetheln/build.mk

$(BUILD_DIR)/repository.stamp: pkg_specs/packages.srs $(wildcard pkg_specs/*.sps) $(shell which gen_deb_repository) | $(BITCOIN_DEPS) $(BITCOIN_RPC_PROXY_DEPS) $(ELECTRS_DEPS) $(ELECTRUM_DEPS) $(TOR_EXTRAS_DEPS) $(LND_DEPS) $(NBXPLORER_DEPS) $(BTCPAYSERVER_DEPS) $(SELFHOST_DEPS) $(RIDETHELN_DEPS)
	gen_deb_repository $< $(BUILD_DIR)
	touch $@

fetch: $(BITCOIN_FETCH_FILES) $(BITCOIN_RPC_PROXY_FETCH_FILES) $(ELECTRS_FETCH_FILES) $(ELECTRUM_FETCH_FILES) $(TOR_EXTRAS_FILES) $(LND_FETCH_FILES) $(NBXPLORER_FETCH_FILES) $(BTCPAYSERVER_FETCH_FILES) $(SELFHOST_FETCH_FILES) $(RIDETHELN_FETCH_FILES)

build-dep: $(BUILD_DIR)/repository.stamp
	sudo apt-get build-dep $(realpath $(BITCOIN_DIR) $(BITCOIN_RPC_PROXY_BUILD_DIR) $(ELECTRS_BUILD_DIR) $(ELECTRUM_BUILD_DIR) $(TOR_EXTRAS_BUILD_DIR) $(LND_BUILD_DIR) $(NBXPLORER_BUILD_DIR) $(BTCPAYSERVER_BUILD_DIR) $(SELFHOST_BUILD_DIR) $(RIDETHELN_BUILD_DIR))

test: $(TEST_DEPS)

test-here: test-here-all-basic test-here-all-nonconfict-upgrade

test-in-qubes-dvm: test-split-$(SPLIT_STRATEGY)

test-split-none:
	$(SOURCE_DIR)/tests/qubes-tools/test-in-dispvm.sh "$(BUILD_DIR)" "$(SOURCE_DIR)" "TEST_ALL_PACKAGES=$(TEST_ALL_PACKAGES)" test-here

test-split-upgrade: test-in-qubes-dvm-all-basic $(addprefix test-in-qubes-dvm-upgrade-,$(TEST_ALL_PACKAGES))

test-split-all: $(addprefix test-in-qubes-dvm-basic-,$(TEST_ALL_PACKAGES)) $(addprefix test-in-qubes-dvm-upgrade-,$(TEST_ALL_PACKAGES))

test-package-%: test-$(TEST_STRATEGY)-basic-%

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
	$(SOURCE_DIR)/tests/qubes-tools/test-in-dispvm.sh "$(BUILD_DIR)" "$(SOURCE_DIR)" "TEST_ALL_PACKAGES=$(TEST_ALL_PACKAGES)" test-here-all-basic

test-in-qubes-dvm-basic-%:
	$(SOURCE_DIR)/tests/qubes-tools/test-in-dispvm.sh "$(BUILD_DIR)" "$(SOURCE_DIR)" "TEST_ALL_PACKAGES=$(TEST_ALL_PACKAGES)" "test-here-basic-$*"

test-in-qubes-dvm-upgrade-%: | test-in-qubes-dvm-all-basic
	$(SOURCE_DIR)/tests/qubes-tools/test-in-dispvm.sh "$(BUILD_DIR)" "$(SOURCE_DIR)" SPLIT_STRATEGY=upgrade "TEST_ALL_PACKAGES=$(TEST_ALL_PACKAGES)" "test-here-upgrade-$*"
