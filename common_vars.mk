MAKEFLAGS += -r
ARCH=$(shell uname -m)

ifeq ($(ARCH),x86_64)
	DEB_ARCH=amd64
endif

