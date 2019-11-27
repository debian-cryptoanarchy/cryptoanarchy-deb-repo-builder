MAKEFLAGS += -r
ARCH=$(shell uname -m)

ifeq ($(ARCH),x86_64)
	DEB_ARCH=amd64
else ifeq ($(ARCH),aarch64)
	DEB_ARCH=arm64
else
	$(error Unsupported architecture)
endif


BUILD_DIR=build
