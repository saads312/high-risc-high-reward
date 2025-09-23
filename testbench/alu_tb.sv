module alu_tb;

// Parameters
parameter DATAW = 32;

// Testbench signals
logic [DATAW-1:0] i_dataa;
logic [DATAW-1:0] i_datab;
logic [3:0] i_op;
logic [2*DATAW-1:0] o_result;
logic carry_out;
logic zero;
logic overflow;
logic negative;

// Expected results
logic [2*DATAW-1:0] expected_result;
logic expected_carry;
logic expected_zero;
logic expected_overflow;
logic expected_negative;

// Test counters
int test_count = 0;
int pass_count = 0;
int fail_count = 0;

// Instantiate the ALU
alu #(.DATAW(DATAW)) dut (
    .i_dataa(i_dataa),
    .i_datab(i_datab),
    .i_op(i_op),
    .o_result(o_result),
    .carry_out(carry_out),
    .zero(zero),
    .overflow(overflow),
    .negative(negative)
);

// Test task
task test_alu_operation(
    input [DATAW-1:0] a,
    input [DATAW-1:0] b,
    input [3:0] op,
    input [2*DATAW-1:0] exp_result,
    input string op_name
);
    i_dataa = a;
    i_datab = b;
    i_op = op;
    expected_result = exp_result;
    
    #1; // Wait for combinational logic
    
    test_count++;
    
    if (o_result == expected_result) begin
        $display("PASS: %s | A=%h, B=%h | Result=%h | Flags: Z=%b, N=%b, C=%b, V=%b", 
                 op_name, a, b, o_result[31:0], zero, negative, carry_out, overflow);
        pass_count++;
    end else begin
        $display("FAIL: %s | A=%h, B=%h | Expected=%h, Got=%h", 
                 op_name, a, b, exp_result[31:0], o_result[31:0]);
        fail_count++;
    end
endtask

// Main test
initial begin
    $display("=== ALU Testbench Starting ===");
    
    // Test ADD operations
    $display("\n--- Testing ADD Operations ---");
    test_alu_operation(32'h00000005, 32'h00000003, 4'b0000, 64'h00000008, "ADD 5+3");
    test_alu_operation(32'h7FFFFFFF, 32'h00000001, 4'b0000, 64'h80000000, "ADD overflow");
    test_alu_operation(32'hFFFFFFFF, 32'h00000001, 4'b0000, 64'h100000000, "ADD with carry");
    test_alu_operation(32'h00000000, 32'h00000000, 4'b0000, 64'h00000000, "ADD zero");
    
    // Test SUB operations
    $display("\n--- Testing SUB Operations ---");
    test_alu_operation(32'h00000005, 32'h00000003, 4'b0001, 64'h00000002, "SUB 5-3");
    test_alu_operation(32'h00000003, 32'h00000005, 4'b0001, 64'hFFFFFFFE, "SUB 3-5");
    test_alu_operation(32'h80000000, 32'h00000001, 4'b0001, 64'h7FFFFFFF, "SUB underflow");
    test_alu_operation(32'h00000005, 32'h00000005, 4'b0001, 64'h00000000, "SUB equal");
    
    // Test AND operations
    $display("\n--- Testing AND Operations ---");
    test_alu_operation(32'h0F0F0F0F, 32'hF0F0F0F0, 4'b0010, 64'h00000000, "AND no overlap");
    test_alu_operation(32'h0F0F0F0F, 32'h0F0F0F0F, 4'b0010, 64'h0F0F0F0F, "AND same");
    test_alu_operation(32'hFFFFFFFF, 32'h12345678, 4'b0010, 64'h12345678, "AND with all 1s");
    
    // Test OR operations
    $display("\n--- Testing OR Operations ---");
    test_alu_operation(32'h0F0F0F0F, 32'hF0F0F0F0, 4'b0011, 64'hFFFFFFFF, "OR complement");
    test_alu_operation(32'h12345678, 32'h87654321, 4'b0011, 64'h97755779, "OR mixed");
    test_alu_operation(32'h00000000, 32'h12345678, 4'b0011, 64'h12345678, "OR with zero");
    
    // Test XOR operations
    $display("\n--- Testing XOR Operations ---");
    test_alu_operation(32'h0F0F0F0F, 32'hF0F0F0F0, 4'b0100, 64'hFFFFFFFF, "XOR complement");
    test_alu_operation(32'h12345678, 32'h12345678, 4'b0100, 64'h00000000, "XOR same");
    test_alu_operation(32'hAAAAAAAA, 32'h55555555, 4'b0100, 64'hFFFFFFFF, "XOR alternating");
    
    // Test SLL operations
    $display("\n--- Testing SLL Operations ---");
    test_alu_operation(32'h00000001, 32'h00000001, 4'b0101, 64'h00000002, "SLL 1<<1");
    test_alu_operation(32'h00000001, 32'h0000001F, 4'b0101, 64'h80000000, "SLL 1<<31");
    test_alu_operation(32'h12345678, 32'h00000004, 4'b0101, 64'h23456780, "SLL by 4");
    
    // Test SRL operations
    $display("\n--- Testing SRL Operations ---");
    test_alu_operation(32'h80000000, 32'h00000001, 4'b0110, 64'h40000000, "SRL 1 bit");
    test_alu_operation(32'hFFFFFFFF, 32'h00000004, 4'b0110, 64'h0FFFFFFF, "SRL by 4");
    test_alu_operation(32'h12345678, 32'h00000008, 4'b0110, 64'h00123456, "SRL by 8");
    
    // Test SRA operations
    $display("\n--- Testing SRA Operations ---");
    test_alu_operation(32'h80000000, 32'h00000001, 4'b0111, 64'hC0000000, "SRA negative");
    test_alu_operation(32'h7FFFFFFF, 32'h00000001, 4'b0111, 64'h3FFFFFFF, "SRA positive");
    test_alu_operation(32'hF0000000, 32'h00000004, 4'b0111, 64'hFF000000, "SRA sign extend");
    
    // Test SLT operations
    $display("\n--- Testing SLT Operations ---");
    test_alu_operation(32'h00000003, 32'h00000005, 4'b1000, 64'h00000001, "SLT 3<5");
    test_alu_operation(32'h00000005, 32'h00000003, 4'b1000, 64'h00000000, "SLT 5<3");
    test_alu_operation(32'h80000000, 32'h00000001, 4'b1000, 64'h00000001, "SLT negative<positive");
    test_alu_operation(32'h00000005, 32'h00000005, 4'b1000, 64'h00000000, "SLT equal");
    
    // Test SLTU operations  
    $display("\n--- Testing SLTU Operations ---");
    test_alu_operation(32'h00000003, 32'h00000005, 4'b1001, 64'h00000001, "SLTU 3<5");
    test_alu_operation(32'h80000000, 32'h00000001, 4'b1001, 64'h00000000, "SLTU unsigned");
    test_alu_operation(32'hFFFFFFFF, 32'h00000001, 4'b1001, 64'h00000000, "SLTU max>1");
    
    // Test edge cases
    $display("\n--- Testing Edge Cases ---");
    test_alu_operation(32'h00000000, 32'h00000000, 4'b0000, 64'h00000000, "ADD zeros");
    test_alu_operation(32'hFFFFFFFF, 32'hFFFFFFFF, 4'b0000, 64'h1FFFFFFFE, "ADD max values");
    
    // Summary
    $display("\n=== Test Summary ===");
    $display("Total tests: %0d", test_count);
    $display("Passed: %0d", pass_count);
    $display("Failed: %0d", fail_count);
    
    if (fail_count == 0) begin
        $display("ALL TESTS PASSED!");
    end else begin
        $display("SOME TESTS FAILED!");
    end
    
    $finish;
end

endmodule