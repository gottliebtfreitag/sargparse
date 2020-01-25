mkfile_path = $(abspath $(INCL))
TARGET=$(shell basename $(shell dirname $(mkfile_path)))
TYPE =
DEPS =

include $(INCL)

$(info )
$(info --------Checking $(TARGET)--------);
.PHONY: all clean
all:
	make -f build_tools/Compile.mk PTARGET=$(TARGET) PTYPE=$(TYPE) VERBOSE=$(VERBOSE) PDEPS="$(DEPS)"

clean:
	make -f build_tools/Compile.mk PTARGET=$(TARGET) PTYPE=$(TYPE) VERBOSE=$(VERBOSE) PDEPS="$(DEPS)" clean

