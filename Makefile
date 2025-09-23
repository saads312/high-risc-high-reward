# Makefile for RISC-V Single-Cycle Processor

# Simulator
SIM = iverilog
VVP = vvp
GTKWAVE = gtkwave

# Source files
SRC_DIR = src
TB_DIR = testbench
SOURCES = $(wildcard $(SRC_DIR)/*.sv)
TESTBENCHES = $(wildcard $(TB_DIR)/*.sv)
CPU_TESTBENCH = $(SRC_DIR)/cpu_top_tb.sv

# Output files
VVP_FILE = cpu_sim
VCD_FILE = cpu_sim.vcd

# Default target
all: simulate

# Compile CPU
compile: $(VVP_FILE)

$(VVP_FILE): $(SOURCES) $(CPU_TESTBENCH)
	$(SIM) -g2012 -o $(VVP_FILE) $(SOURCES) $(CPU_TESTBENCH)

# Simulate CPU
simulate: $(VVP_FILE)
	$(VVP) $(VVP_FILE)

# Component testbenches
test-alu:
	$(SIM) -g2012 -o alu_test $(SRC_DIR)/alu.sv $(TB_DIR)/alu_tb.sv
	$(VVP) alu_test

test-ctrl:
	$(SIM) -g2012 -o ctrl_test $(SRC_DIR)/ctrl.sv $(TB_DIR)/ctrl_tb.sv
	$(VVP) ctrl_test

test-regfile:
	$(SIM) -g2012 -o regfile_test $(SRC_DIR)/reg_file.sv $(TB_DIR)/reg_file_tb.sv
	$(VVP) regfile_test

test-extender:
	$(SIM) -g2012 -o extender_test $(SRC_DIR)/extender.sv $(TB_DIR)/extender_tb.sv
	$(VVP) extender_test

# Run all component tests
test-all-components: test-alu test-ctrl test-regfile test-extender
	@echo "All component tests completed!"

# Simulate with VCD output
simulate_vcd: $(VVP_FILE)
	$(VVP) $(VVP_FILE) -vcd

# View waveforms
wave: $(VCD_FILE)
	$(GTKWAVE) $(VCD_FILE)

# Clean
clean:
	rm -f $(VVP_FILE) $(VCD_FILE) *_test

# Help
help:
	@echo "Available targets:"
	@echo "  all                  - Compile and simulate CPU"
	@echo "  compile              - Compile the CPU design"
	@echo "  simulate             - Run CPU simulation"
	@echo "  test-alu             - Test ALU component"
	@echo "  test-ctrl            - Test Control Unit component"
	@echo "  test-regfile         - Test Register File component"
	@echo "  test-extender        - Test Extender component"
	@echo "  test-all-components  - Run all component tests"
	@echo "  wave                 - View waveforms with GTKWave"
	@echo "  clean                - Remove generated files"
	@echo "  help                 - Show this help"

.PHONY: all compile simulate simulate_vcd wave clean help test-alu test-ctrl test-regfile test-extender test-all-components
