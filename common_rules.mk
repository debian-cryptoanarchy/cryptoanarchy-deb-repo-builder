SQCK=$(shell which sqck || true)

ifeq ($(SQCK),)
	KEY_INPUT_SUFFIX=-raw.gpg
else
	KEY_INPUT_SUFFIX=-sqck.gpg
endif

$(BUILD_DIR)/%-sqck.gpg: $(BUILD_DIR)/%-sqck.key
	gpg --no-default-keyring --keyring $@ --import $<

# We split verification because sqck must not be followed by |
# as shell would ignore the exit code of sqck.
$(BUILD_DIR)/%-sqck.key: $(BUILD_DIR)/%-raw.gpg
	gpg --no-default-keyring --keyring $< --export $* | $(SQCK) $* > $@

$(BUILD_DIR)/%-raw.gpg: | $(BUILD_DIR)
	gpg --no-default-keyring --keyring $@ --keyserver hkp://keyserver.ubuntu.com --recv-keys $*

$(BUILD_DIR):
	mkdir -p $@

$(BUILD_DIR)/debcrafter-%.stamp: pkg_specs/%.sss pkg_specs/%.changelog $(BUILD_DIR)/%.d $(BUILD_DIR)/verify-%.stamp $(shell which gen_deb_repository)
	DEBEMAIL=$(MAINTAINER) gen_deb_repository $< $(BUILD_DIR) --split-source --write-deps $(BUILD_DIR)/$*.d
	touch $@

$(BUILD_DIR)/packages-%.stamp: $(BUILD_DIR)/debcrafter-%.stamp
	cd "$(BUILD_DIR)/$*-`head -n 1 pkg_specs/$*.changelog | sed -e 's/^.*(\([^)]*\)).*$$/\1/' -e 's/-[0-9]*$$//'`" && SOURCE_DATE_EPOCH=`dpkg-parsechangelog -STimestamp` dpkg-buildpackage -a $(DEB_ARCH) $(BUILD_PACKAGE_FLAGS) && find debian -exec touch -d @`dpkg-parsechangelog -STimestamp` '{}' \;
	touch $@

$(BUILD_DIR)/build-%.mk: $(SOURCE_DIR)build_rules/%.yaml $(SOURCE_DIR)build_template.mustache | $(BUILD_DIR)
	mustache $^ > $@

$(BUILD_DIR)/%.d: ;

.PRECIOUS: $(BUILD_DIR)/%.d

-include $(addprefix $(BUILD_DIR)/build-,$(addsuffix .mk,$(SOURCES)))
include $(wildcard $(BUILD_DIR)/*.d)

.PHONY: all clean
