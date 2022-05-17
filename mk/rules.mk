#######################################
# MAIN COMPILING RULES
#######################################
# list of c objects
OBJECTS := $(addprefix $(BUILD_DIR)/,$(C_SOURCES:.c=.o))
# list of cpp objects
OBJECTS := $(OBJECTS) $(addprefix $(BUILD_DIR)/,$(CPP_SOURCES:.cpp=.o))
# list of asm objects
OBJECTS := $(OBJECTS) $(addprefix $(BUILD_DIR)/,$(ASM_SOURCES:.s=.o))
# list of lib objects. The purpose of creating a lib folder is to separate compiling options from user code and lib code, see line 20 below
LIBOBJECTS := $(addprefix $(BUILD_DIR)/lib/,$(LIB_C_SOURCES:.c=.o))
LIBOBJECTS += $(addprefix $(BUILD_DIR)/lib/,$(LIB_CC_SOURCES:.cc=.o))
LIBOBJECTS += $(addprefix $(BUILD_DIR)/lib/,$(LIB_CPP_SOURCES:.cpp=.o))

$(TARGET): $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin $(BUILD_DIR)/disassembly.S $(BUILD_DIR)/$(TARGET).file_sizeinfo

$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(@D)
	@if [ $(V) -gt 1 ] && [ $(V) -lt 4 ];then echo "  CC        $<"; fi
	$(Q)$(CC) -c $(CFLAGS) $(GEN_DEPS) $(SAVE_TEMPS) $< -o $@
	$(Q)$(DEMANGLE_IF_GENERATE_ASSEMBLY)

# separate compiling options from user code and lib code
$(BUILD_DIR)/lib/%.o: %.c
	@mkdir -p $(@D)
	@if [ $(V) -gt 1 ] && [ $(V) -lt 4 ];then echo "  CC (lib)  $<"; fi
	$(Q)$(CC) -c $(filter-out -Werror,$(LIB_C_FLAGS)) $(GEN_DEPS) $< -o $@

$(BUILD_DIR)/lib/%.o: %.cc
	@mkdir -p $(@D)
	@if [ $(V) -gt 1 ] && [ $(V) -lt 4 ];then echo "  CXX (lib)  $<"; fi
	$(Q)$(CXX) -c $(filter-out -Werror,$(LIB_CXX_FLAGS)) $(GEN_DEPS) $< -o $@

$(BUILD_DIR)/lib/%.o: %.cpp
	@mkdir -p $(@D)
	@if [ $(V) -gt 1 ] && [ $(V) -lt 4 ];then echo "  CXX (lib)  $<"; fi
	$(Q)$(CXX) -c $(filter-out -Werror,$(LIB_CXX_FLAGS)) $(GEN_DEPS) $< -o $@

$(BUILD_DIR)/%.o: %.cpp
	@mkdir -p $(@D)
	@if [ $(V) -gt 1 ] && [ $(V) -lt 4 ];then echo "  CXX       $<"; fi
	$(Q)$(CXX) -c $(CXXFLAGS) $(GEN_DEPS) $(SAVE_TEMPS) $< -o $@
	$(Q)$(DEMANGLE_IF_GENERATE_ASSEMBLY)

$(BUILD_DIR)/%.o: %.s
	@mkdir -p $(@D)
	@if [ $(V) -gt 1 ] && [ $(V) -lt 4 ];then echo "  ASM       $<"; fi
	$(Q)$(AS) -c $(ASFLAGS) $< -o $@

$(BUILD_DIR)/$(TARGET).elf: $(LIBOBJECTS) $(OBJECTS) $(LDSCRIPT)
	@mkdir -p $(@D)
	@echo
	@echo "  ${COLOR_YELLOW}Linking objects...${NO_COLOR}"
	@echo
	$(Q)$(CXX) $(LIBOBJECTS) $(OBJECTS) $(LDFLAGS) -o $@
	@echo
	$(Q)$(SZ) $@
	@echo
	@echo "  [${COLOR_GREEN}$(TARGET)${NO_COLOR}] has been built in ${COLOR_BLUE}$(BUILD_DIR)${NO_COLOR} folder."

$(BUILD_DIR)/disassembly.S: $(BUILD_DIR)/$(TARGET).elf
	$(Q)$(OBJDUMP) --disassemble --line-numbers --reloc --wide --demangle $< > $@
# $(Q)$(OBJDUMP) --source --no-show-raw-insn --disassemble --line-numbers --reloc --wide --demangle --no-addresses $< > $@

$(BUILD_DIR)/$(TARGET).symbol_info: $(BUILD_DIR)/$(TARGET).elf
	$(Q)$(NM) --print-size --line-numbers --size-sort --demangle $< > $@

$(BUILD_DIR)/$(TARGET).file_sizeinfo: $(BUILD_DIR)/$(TARGET).symbol_info
	$(Q)python3 mk/print_size_info.py $< > $@

$(BUILD_DIR)/$(TARGET).hex: $(BUILD_DIR)/$(TARGET).elf
	$(Q)$(HEX) $< $@

$(BUILD_DIR)/$(TARGET).bin: $(BUILD_DIR)/$(TARGET).elf
	$(Q)$(BIN) $< $@

#######################################
# CPPCHECK
#######################################
.PHONY: check-cppcheck
CPPCHECK := cppcheck
CPPCHECK_FLAGS := --enable=all --suppress=*:*$(SOURCES)/boot/cmsis_startup/* --suppress=missingInclude --suppress=unusedFunction --suppress=unmatchedSuppression
CPPCHECK_FLAGS += --inline-suppr ${COMPILER_DEFINES} $(INCLUDES)
check-cppcheck:
	$(Q)$(CPPCHECK) $(CPPCHECK_FLAGS) --addon=misra.json $(C_SOURCES)
	$(Q)$(CPPCHECK) $(CPPCHECK_FLAGS) --addon=misra_cpp.json $(CPP_SOURCES)
	@echo
	@echo "All cppcheck checks have passed!"

#######################################
# CLANG-TIDY
#######################################
.PHONY: check-clang-tidy
CLANG_TIDY := clang-tidy # the checking flags are written in the .clang-tidy config file
check-clang-tidy:
	$(Q)$(CLANG_TIDY) --quiet $(C_SOURCES) --warnings-as-errors=* -extra-arg=$(C_STD) -- $(INCLUDES) ${COMPILER_DEFINES}
	$(Q)$(CLANG_TIDY) --quiet $(CPP_SOURCES) --warnings-as-errors=* -extra-arg=$(CPP_STD) -- $(INCLUDES) ${COMPILER_DEFINES}
	@echo
	@echo "All clang-tidy checks have passed!"

#######################################
# FORMAT-CHECK
#######################################
.PHONY: check-format
CLANG_FORMAT := clang-format # the checking flags are written in the .clang-tidy config file
USER_INCLUDE_HEADERS := $(foreach includeDir,$(USER_INCLUDE_PATH),$(wildcard $(includeDir)/*.h))
USER_INCLUDE_HEADERS += $(foreach includeDir,$(USER_INCLUDE_PATH),$(wildcard $(includeDir)/*.hh))
check-format:
	$(Q)$(CLANG_FORMAT) --dry-run --Werror $(CPP_SOURCES) $(C_SOURCES) $(USER_INCLUDE_HEADERS)
	@echo
	@echo "All format checks have passed!"

#######################################
# CHECK-ALL
#######################################
# static analysis and format check
.PHONY: check-all
check-all: check-cppcheck check-clang-tidy check-format

#######################################
# FLASH
#######################################
.PHONY: upload
upload: $(BUILD_DIR)/$(TARGET).hex
	@echo
	@echo "  ${COLOR_YELLOW}Uploading ${COLOR_GREEN}$(TARGET)${COLOR_YELLOW} to device ${COLOR_GREEN}$(TARGET_DEVICE)${COLOR_YELLOW} ...${NO_COLOR}"
	$(Q)./flash-programmer jlink $(TARGET_DEVICE) $(BUILD_DIR)/$(TARGET).hex
	@echo "  ${COLOR_YELLOW}Upload success!${NO_COLOR}"

#######################################
# CCACHE
#######################################
.PHONY: ccache-stats ccache-clear ccache-reset ccache-config
ccache-stats:
	@$(CCACHE) -sv
ccache-clear:
	@$(CCACHE) -C
ccache-reset: ccache-clear
	@$(CCACHE) -z
ccache-config:
	@$(CCACHE) -p

#######################################
# CLEAN
#######################################
.PHONY: clean
clean:
	@rm $(BUILD_DIR)/* 2> /dev/null || true
	@rm -rf $(BUILD_DIR)/source
	@echo "  User build folder is deleted."

.PHONY: distclean
distclean:
	$(Q)rm -rf $(BUILD_DIR)
	@echo "  User build and lib build folder is deleted."

#######################################
# DEPENDENCIES
#######################################
DEPFILES := $(addprefix $(BUILD_DIR)/,$(C_SOURCES:.c=.d))
DEPFILES += $(addprefix $(BUILD_DIR)/,$(CPP_SOURCES:.cpp=.d))
DEPFILES += $(addprefix $(BUILD_DIR)/lib/,$(LIB_C_SOURCES:.c=.d))
DEPFILES += $(addprefix $(BUILD_DIR)/lib/,$(LIB_CPP_SOURCES:.cpp=.d))
DEPFILES += $(addprefix $(BUILD_DIR)/lib/,$(LIB_CC_SOURCES:.cc=.d))
-include $(DEPFILES)
