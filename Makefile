mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
root_dir := $(shell dirname $(shell realpath --relative-to $(shell pwd) $(mkfile_path)))

ALL_TARGETS:=$(subst /Makefile,,$(shell realpath --relative-to $(root_dir)/src $(wildcard $(root_dir)/src/*/Makefile)))

ALL_TARGETS_CLEAN:=$(foreach TARGET, $(ALL_TARGETS), $(addsuffix -clean,$(TARGET)))
ALL_TARGETS_A:=$(foreach TARGET, $(ALL_TARGETS), $(addsuffix .a,$(TARGET)))


.PHONY: all clean $(ALL_TARGETS) $(ALL_TARGETS_CLEAN)
all: $(ALL_TARGETS)

$(ALL_TARGETS):
	make -f build_tools/Jump.mk VERBOSE=$(VERBOSE) INCL="$(root_dir)/src/$@/Makefile"

$(ALL_TARGETS_A):
	make -f build_tools/Jump.mk VERBOSE=$(VERBOSE) INCL="$(root_dir)/src/$(subst .a,,$@/Makefile)"


$(ALL_TARGETS_CLEAN):
	make -f build_tools/Jump.mk VERBOSE=$(VERBOSE) INCL="$(root_dir)/src/$(subst -clean,,$@)/Makefile" clean

clean:
	make $(ALL_TARGETS_CLEAN)

