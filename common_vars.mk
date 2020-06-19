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

$(BUILD_DIR)/vars-%.mk: $(SOURCE_DIR)build_rules/%.yaml $(SOURCE_DIR)vars_template.mustache | $(BUILD_DIR)
	mustache $^ > $@

.PRECIOUS: $(BUILD_DIR)/vars-%.mk

-include $(addprefix $(BUILD_DIR)/vars-,$(addsuffix .mk,$(SOURCES)))
