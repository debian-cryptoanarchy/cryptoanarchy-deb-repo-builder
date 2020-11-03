ifeq ($(ARCH),x86_64)
	BITCOIN_ARCH=x86_64-linux-gnu
else ifeq ($(ARCH),armv7l)
	BITCOIN_ARCH=arm-linux-gnueabihf
else ifeq ($(ARCH),aarch64)
	BITCOIN_ARCH=aarch64-linux-gnu
else
	$(error Unsupported architecture)
endif
