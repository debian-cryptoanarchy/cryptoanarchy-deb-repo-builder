ifeq ($(ARCH),x86_64)
	LND_ARCH=amd64
else ifeq ($(ARCH),aarch64)
	LND_ARCH=arm64
else
	$(error Unsupported architecture)
endif

LND_ARCH_LONG=linux-$(LND_ARCH)
