# Makefile for RISC-V Single-Cycle Processor

# Simulator
SIM = iverilog
VVP = vvp
GTKWAVE = gtkwave

# Source files
SRC_DIR = src
SOURCES = $(wildcard $(SRC_DIR)/*.sv)
TESTBENCH = $(SRC_DIR)/cpu_top_tb.sv
TOP_MODULE = cpu_top_tb

# Output files
VVP_FILE = cpu_sim
VCD_FILE = cpu_sim.vcd

# Default target
all: simulate

# Compile
compile: $(VVP_FILE)

$(VVP_FILE): $(SOURCES) $(TESTBENCH)
	$(SIM) -g2012 -o $(VVP_FILE) $(SOURCES) $(TESTBENCH)

# Simulate
simulate: $(VVP_FILE)
	$(VVP) $(VVP_FILE)

# Simulate with VCD output
simulate_vcd: $(VVP_FILE)
	$(VVP) $(VVP_FILE) -vcd

# View waveforms
wave: $(VCD_FILE)
	$(GTKWAVE) $(VCD_FILE)

# Clean
clean:
	rm -f $(VVP_FILE) $(VCD_FILE)

# Help
help:
	@echo "Available targets:"
	@echo "  all        - Compile and simulate"
	@echo "  compile    - Compile the design"
	@echo "  simulate   - Run simulation"
	@echo "  wave       - View waveforms with GTKWave"
	@echo "  clean      - Remove generated files"
	@echo "  help       - Show this help"

.PHONY: all compile simulate simulate_vcd wave clean help