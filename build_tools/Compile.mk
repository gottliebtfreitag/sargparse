CROSS_COMPILE_PREFIX =
CC      ?= $(CROSS_COMPILE_PREFIX)gcc
CXX     ?= $(CROSS_COMPILE_PREFIX)g++
AR      ?= $(CROSS_COMPILE_PREFIX)ar
SIZE    ?= $(CROSS_COMPILE_PREFIX)size

SRC_FOLDERS = src/
LIBS = c
LIB_PATHS =
INCLUDES = src/

SRC_FOLDERS = src/$(PTARGET)

INCLUDE_CMD = $(addprefix -I, $(INCLUDES))
LIB_CMD = $(addprefix -l, $(LIBS))
LIB_PATH_CMD = $(addprefix -L, $(LIB_PATHS))

# Flags
DEFINES      +=

FP_FLAGS     ?=
COMMON_FLAGS += $(DEFINES) $(FP_FLAGS)
COMMON_FLAGS += -O0 -g3
COMMON_FLAGS += $(INCLUDE_CMD)

#COMMON_FLAGS    += -fsanitize=address

# Warnings
W_FLAGS      += -Wextra -Wredundant-decls
W_FLAGS      += -Wall -Wundef

###############################################################################
# C flags

CFLAGS		+= $(COMMON_FLAGS)
CFLAGS		+= $(W_FLAGS)
CFLAGS      += -Wimplicit-function-declaration -Wmissing-prototypes -Wstrict-prototypes

###############################################################################
# C++ flags

CPPFLAGS	+= $(COMMON_FLAGS)
CPPFLAGS	+= $(W_FLAGS)
CPPFLAGS	+= -std=c++17
CPPFLAGS	+= -I$(INCLUDE_DIR)
CPPFLAGS    += -gsplit-dwarf


###############################################################################
# Linker flags

LINKERFLAGS +=  $(COMMON_FLAGS)
LINKERFLAGS += -fuse-ld=gold
LINKERFLAGS += -Wl,--gdb-index
#LINKERFLAGS += -s

CPP_SUFFIX   = .cpp
C_SUFFIX     = .c
OBJ_SUFFIX   = .o
DEP_SUFFIX   = .d
OBJ_ROOT_DIR = obj/
OBJ_DIR      = $(OBJ_ROOT_DIR)$(PTARGET)/

IGNORE_STRINGS = /archive/
#IGNORE_STRINGS = /test/

CPP_FILES            += $(sort $(filter-out $(IGNORE_STRINGS), $(foreach SRC_FOLDER, $(SRC_FOLDERS), $(shell find $(SRC_FOLDER) -name "*$(CPP_SUFFIX)" | grep -v $(addprefix -e, $(IGNORE_STRINGS))))))
C_FILES              += $(sort $(filter-out $(IGNORE_STRINGS), $(foreach SRC_FOLDER, $(SRC_FOLDERS), $(shell find $(SRC_FOLDER) -name "*$(C_SUFFIX)" | grep -v $(addprefix -e, $(IGNORE_STRINGS))))))

CPP_OBJ_FILES        += $(addsuffix $(OBJ_SUFFIX), $(addprefix $(OBJ_DIR), $(CPP_FILES)))
C_OBJ_FILES          += $(addsuffix $(OBJ_SUFFIX), $(addprefix $(OBJ_DIR), $(C_FILES)))

OBJ_FILES             = $(CPP_OBJ_FILES) $(C_OBJ_FILES)

DEP_FILES            += $(addsuffix $(DEP_SUFFIX), $(OBJ_FILES))

#### makefile magic

HASH_SUFFIX    = _hash
LINKER_HASH    = $(OBJ_DIR)$(shell echo $(OBJ_FILES) $(LINKERFLAGS) $(LIB_PATH_CMD) $(LIB_CMD) | md5sum | cut -d ' ' -f 1).linker$(HASH_SUFFIX)
CPP_FLAGS_HASH = $(OBJ_DIR)$(shell echo $(CPPFLAGS) | md5sum | cut -d ' ' -f 1).cpp_flags$(HASH_SUFFIX)
C_FLAGS_HASH   = $(OBJ_DIR)$(shell echo $(CFLAGS) | md5sum | cut -d ' ' -f 1).c_flags$(HASH_SUFFIX)

$(info $(LINKER_HASH))

ifndef VERBOSE
SILENT = @
endif


.phony: all clean dbg $(PDEPS)
all: $(PTARGET)$(PTYPE)

.PRECIOUS: $(CPP_FLAGS_HASH) $(C_FLAGS_HASH)

dbg:
	@ echo $(C_FLAGS_HASH)
	@ echo $(CPP_FLAGS_HASH)

clean:
	$(SILENT) rm -rf $(OBJ_DIR) $(PTARGET)$(PTYPE)
	$(SILENT) rmdir -p --ignore-fail-on-non-empty $(OBJ_ROOT_DIR)

$(PDEPS):
	$(SILENT) make $(PDEPS)

#ifeq ($(PTYPE),)
#BUILD_TYPE=$(PTARGET).exe
#else
#BUILD_TYPE=$(PTARGET)$(PTYPE)
#endif
#
#$(PTARGET): $(BUILD_TYPE)
#	$(info )
#	$(info --------Building $(PTARGET)--------)

$(info $(PTARGET)$(PTYPE))
ifeq ($(PTYPE),)
$(PTARGET): $(OBJ_FILES) $(LINKER_HASH) $(PDEPS)
	$(info )
	$(info --------Building $(PTARGET)--------)
	@ echo linking $(PTARGET)
	$(SILENT) $(CXX) -o $(PTARGET) $(OBJ_FILES) $(PDEPS) $(LINKERFLAGS) $(LIB_PATH_CMD) $(LIB_CMD)
	$(SILENT) $(SIZE) $(PTARGET)
	@ echo done
else ifeq ($(PTYPE),.a)
$(PTARGET).a: $(OBJ_FILES) $(LINKER_HASH) $(PDEPS)
	$(info )
	$(info --------Building $(PTARGET)--------)
	@ echo linking $@
	$(SILENT) ar rcs $@ $(OBJ_FILES)
	$(SILENT) $(SIZE) $@
	@ echo done
endif
$(OBJ_DIR)%$(HASH_SUFFIX): | $(OBJ_DIR) $(OBJ_DIR)$(PTARGET)
	$(SILENT) rm -f $(OBJ_DIR)*$(suffix $@)
	$(SILENT) touch $@

$(OBJ_DIR) $(OBJ_DIR)$(PTARGET):
	$(SILENT) mkdir -p $@

$(OBJ_DIR)%$(C_SUFFIX)$(OBJ_SUFFIX): %$(C_SUFFIX) $(C_FLAGS_HASH) | $(OBJ_DIR)
	@ echo building $<
	@ mkdir -p $(dir $@)
	$(SILENT) $(CC) $(CFLAGS) -o $@ -c $<

	@ $(CC) $(CFLAGS) -MM -MF $(OBJ_DIR)$<$(DEP_SUFFIX) -c $<
	@ sed -i -e 's|.*:|$@:|' $(OBJ_DIR)$<$(DEP_SUFFIX)

$(OBJ_DIR)%$(CPP_SUFFIX)$(OBJ_SUFFIX): %$(CPP_SUFFIX) $(CPP_FLAGS_HASH) | $(OBJ_DIR)
	@echo building $<
	@ mkdir -p $(dir $@)
	$(SILENT) $(CXX) $(CPPFLAGS) -o $@ -c $<

	@ $(CXX) $(CPPFLAGS) -MM -MF $@$(DEP_SUFFIX) -c $<
	@ sed -i -e 's|.*:|$@:|' $@$(DEP_SUFFIX)

-include $(DEP_FILES)
