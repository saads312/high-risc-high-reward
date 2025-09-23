# Component Testbenches

This directory contains comprehensive testbenches for key components of the single-cycle RISC-V processor.

## Available Testbenches

### 1. ALU Testbench (`alu_tb.sv`)
Tests the Arithmetic Logic Unit with comprehensive coverage of all operations:
- **ADD/SUB**: Basic arithmetic with overflow/underflow detection
- **Logical Operations**: AND, OR, XOR with various bit patterns
- **Shift Operations**: SLL, SRL, SRA with different shift amounts
- **Comparison**: SLT (signed) and SLTU (unsigned) comparisons
- **Flag Testing**: Zero, negative, carry, and overflow flags

**Key Test Cases:**
- Edge cases (max/min values, zero operands)
- Overflow and underflow conditions
- All supported ALU operations (10 total)
- Flag generation verification

### 2. Control Unit Testbench (`ctrl_tb.sv`)
Tests the main control unit that generates all control signals:
- **R-type Instructions**: ADD, SUB, AND, OR, SLT
- **I-type Instructions**: ADDI, SLTI, ANDI, ORI, LW, JALR
- **S-type Instructions**: SW with various offsets
- **B-type Instructions**: BEQ with branch taken/not taken scenarios
- **Unknown Instructions**: Default behavior verification

**Key Test Cases:**
- All major instruction types with proper control signal generation
- Branch decision logic (PC_src based on zero flag)
- Immediate source selection for different instruction formats
- ALU operation encoding verification

### 3. Register File Testbench (`reg_file_tb.sv`)
Tests the 32-register file with comprehensive read/write scenarios:
- **Basic Operations**: Read/write to all 32 registers
- **x0 Immutability**: Ensures x0 always reads zero and cannot be written
- **Write Enable**: Verifies write enable control functionality
- **Simultaneous Operations**: Read and write in the same cycle
- **Reset Behavior**: All registers initialize to zero

**Key Test Cases:**
- Write unique values to all registers (except x0)
- Verify x0 protection against writes
- Simultaneous read/write operations
- Write enable control testing
- Reset and initialization verification

### 4. Extender Testbench (`extender_tb.sv`)
Tests immediate value generation for all instruction formats:
- **I-type**: 12-bit signed immediate (ADDI, LW, JALR)
- **S-type**: 12-bit signed immediate (SW)
- **B-type**: 13-bit signed immediate with LSB=0 (BEQ)
- **U-type**: 20-bit immediate in upper bits (LUI, AUIPC)
- **J-type**: 21-bit signed immediate with LSB=0 (JAL)

**Key Test Cases:**
- Sign extension verification for all formats
- Maximum positive and negative values
- Zero and edge case handling
- Bit pattern reconstruction for complex formats (B-type, J-type)
- Unknown opcode default behavior

## Running the Tests

### Individual Component Tests
```bash
# Test ALU
make test-alu

# Test Control Unit  
make test-ctrl

# Test Register File
make test-regfile

# Test Extender
make test-extender
```

### Run All Component Tests
```bash
make test-all-components
```

### View Available Targets
```bash
make help
```

## Test Output

Each testbench provides:
- **PASS/FAIL** status for each test case
- **Detailed logging** of inputs, expected vs actual outputs
- **Test summary** with pass/fail counts
- **Comprehensive coverage** of normal and edge cases

Example output:
```
=== ALU Testbench Starting ===

--- Testing ADD Operations ---
PASS: ADD 5+3 | A=00000005, B=00000003 | Result=00000008 | Flags: Z=0, N=0, C=0, V=0
PASS: ADD overflow | A=7FFFFFFF, B=00000001 | Result=80000000 | Flags: Z=0, N=1, C=0, V=1

=== Test Summary ===
Total tests: 45
Passed: 45  
Failed: 0
ALL TESTS PASSED!
```

## Adding New Tests

To add new test cases to any testbench:

1. **Locate the test task**: Each testbench has helper tasks like `test_alu_operation()`, `test_control_signals()`, etc.

2. **Add test case**: Call the test task with appropriate parameters:
   ```systemverilog
   test_alu_operation(32'hA, 32'hB, 4'b0000, 64'h15, "ADD custom test");
   ```

3. **Update documentation**: Add description of new test cases to this README.

## Component Integration

These testbenches verify individual component functionality. For full processor testing, use the main CPU testbench:
```bash
make simulate
```

The component testbenches help isolate issues and verify correct implementation before integration testing.