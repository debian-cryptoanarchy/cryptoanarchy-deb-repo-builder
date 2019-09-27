BITCOIN_SOURCE_DIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))

include $(BITCOIN_SOURCE_DIR)../common_vars.mk
include $(BITCOIN_SOURCE_DIR)vars.mk

all: $(BITCOIN_PACKAGES)

clean: clean_bitcoin

include $(BITCOIN_SOURCE_DIR)build.mk
