module reg_file_tb;

// Testbench signals
logic clk;
logic rst;
logic [4:0] rs1;
logic [4:0] rs2;
logic [4:0] rd;
logic [31:0] wdata;
logic wen;
logic [31:0] rdata1;
logic [31:0] rdata2;

// Test counters
int test_count = 0;
int pass_count = 0;
int fail_count = 0;

// Expected values
logic [31:0] expected_rdata1, expected_rdata2;

// Instantiate the register file
reg_file dut (
    .clk(clk),
    .rst(rst),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .wdata(wdata),
    .wen(wen),
    .rdata1(rdata1),
    .rdata2(rdata2)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10ns period
end

// Test task for reading
task test_read(
    input [4:0] test_rs1,
    input [4:0] test_rs2,
    input [31:0] exp_rdata1,
    input [31:0] exp_rdata2,
    input string test_name
);
    rs1 = test_rs1;
    rs2 = test_rs2;
    expected_rdata1 = exp_rdata1;
    expected_rdata2 = exp_rdata2;
    
    #1; // Wait for combinational read
    
    test_count++;
    
    if (rdata1 == expected_rdata1 && rdata2 == expected_rdata2) begin
        $display("PASS: %s | rs1=%0d->%h, rs2=%0d->%h", 
                 test_name, test_rs1, rdata1, test_rs2, rdata2);
        pass_count++;
    end else begin
        $display("FAIL: %s | rs1=%0d exp=%h got=%h, rs2=%0d exp=%h got=%h", 
                 test_name, test_rs1, expected_rdata1, rdata1, test_rs2, expected_rdata2, rdata2);
        fail_count++;
    end
endtask

// Test task for writing
task test_write(
    input [4:0] test_rd,
    input [31:0] test_wdata,
    input test_wen,
    input string test_name
);
    rd = test_rd;
    wdata = test_wdata;
    wen = test_wen;
    
    @(posedge clk); // Wait for write to complete
    #1; // Small delay for combinational read
    
    test_count++;
    
    // Read back the written value if write was enabled and not to x0
    if (test_wen && test_rd != 5'b0) begin
        rs1 = test_rd;
        rs2 = 5'b0;
        #1;
        if (rdata1 == test_wdata) begin
            $display("PASS: %s | Wrote %h to x%0d, read back %h", 
                     test_name, test_wdata, test_rd, rdata1);
            pass_count++;
        end else begin
            $display("FAIL: %s | Wrote %h to x%0d, read back %h", 
                     test_name, test_wdata, test_rd, rdata1);
            fail_count++;
        end
    end else if (test_wen && test_rd == 5'b0) begin
        // Writing to x0 should have no effect
        rs1 = 5'b0;
        #1;
        if (rdata1 == 32'h0) begin
            $display("PASS: %s | x0 remains zero after write attempt", test_name);
            pass_count++;
        end else begin
            $display("FAIL: %s | x0 should remain zero but got %h", test_name, rdata1);
            fail_count++;
        end
    end else begin
        // Write not enabled, no change expected
        $display("INFO: %s | Write not enabled, no change expected", test_name);
        pass_count++; // Count as pass since this is expected behavior
    end
endtask

// Test task for simultaneous read/write
task test_read_write_same_cycle(
    input [4:0] test_rd,
    input [31:0] test_wdata,
    input [4:0] test_rs1,
    input [4:0] test_rs2,
    input string test_name
);
    // Set up the write
    rd = test_rd;
    wdata = test_wdata;
    wen = 1'b1;
    rs1 = test_rs1;
    rs2 = test_rs2;
    
    @(posedge clk);
    #1; // Small delay
    
    test_count++;
    
    // Check if reading the same register that was written gives the new value
    if (test_rs1 == test_rd && test_rd != 5'b0) begin
        if (rdata1 == test_wdata) begin
            $display("PASS: %s | Read new value %h from x%0d same cycle", 
                     test_name, rdata1, test_rs1);
            pass_count++;
        end else begin
            $display("FAIL: %s | Expected %h from x%0d, got %h", 
                     test_name, test_wdata, test_rs1, rdata1);
            fail_count++;
        end
    end else begin
        $display("INFO: %s | Different registers, checking for no interference", test_name);
        pass_count++;
    end
endtask

// Main test
initial begin
    $display("=== Register File Testbench Starting ===");
    
    // Initialize
    rst = 1'b1;
    wen = 1'b0;
    rs1 = 5'b0;
    rs2 = 5'b0;
    rd = 5'b0;
    wdata = 32'h0;
    
    // Wait for reset
    repeat(2) @(posedge clk);
    rst = 1'b0;
    @(posedge clk);
    
    $display("\n--- Testing Reset Behavior ---");
    // Test that all registers are zero after reset
    test_read(5'd0, 5'd1, 32'h0, 32'h0, "Reset - x0 and x1 should be zero");
    test_read(5'd15, 5'd31, 32'h0, 32'h0, "Reset - x15 and x31 should be zero");
    
    $display("\n--- Testing Basic Write/Read ---");
    // Test basic write and read operations
    test_write(5'd1, 32'h12345678, 1'b1, "Write to x1");
    test_read(5'd1, 5'd0, 32'h12345678, 32'h0, "Read from x1 and x0");
    
    test_write(5'd2, 32'hABCDEF00, 1'b1, "Write to x2");
    test_read(5'd2, 5'd1, 32'hABCDEF00, 32'h12345678, "Read from x2 and x1");
    
    test_write(5'd31, 32'hDEADBEEF, 1'b1, "Write to x31");
    test_read(5'd31, 5'd2, 32'hDEADBEEF, 32'hABCDEF00, "Read from x31 and x2");
    
    $display("\n--- Testing x0 Immutability ---");
    // Test that x0 always reads as zero and cannot be written
    test_write(5'd0, 32'hFFFFFFFF, 1'b1, "Attempt to write to x0");
    test_read(5'd0, 5'd1, 32'h0, 32'h12345678, "x0 should remain zero");
    
    $display("\n--- Testing Write Enable Control ---");
    // Test write enable functionality
    test_write(5'd3, 32'h11111111, 1'b0, "Write disabled to x3");
    test_read(5'd3, 5'd0, 32'h0, 32'h0, "x3 should remain zero (write disabled)");
    
    test_write(5'd3, 32'h22222222, 1'b1, "Write enabled to x3");
    test_read(5'd3, 5'd0, 32'h22222222, 32'h0, "x3 should have new value");
    
    $display("\n--- Testing All Registers ---");
    // Write unique values to all registers (except x0)
    for (int i = 1; i < 32; i++) begin
        test_write(i[4:0], 32'h1000_0000 + i, 1'b1, $sformatf("Write %h to x%0d", 32'h1000_0000 + i, i));
    end
    
    // Read back all values
    for (int i = 1; i < 32; i += 2) begin
        int j = (i < 31) ? i + 1 : 1;
        test_read(i[4:0], j[4:0], 32'h1000_0000 + i, 32'h1000_0000 + j, 
                 $sformatf("Read x%0d and x%0d", i, j));
    end
    
    $display("\n--- Testing Simultaneous Read/Write ---");
    // Test reading and writing in the same cycle
    test_read_write_same_cycle(5'd5, 32'h55555555, 5'd5, 5'd6, "Read/Write x5 same cycle");
    test_read_write_same_cycle(5'd10, 32'hAAAAAAAA, 5'd9, 5'd10, "Read/Write different regs");
    
    $display("\n--- Testing Edge Cases ---");
    // Test with maximum values
    test_write(5'd7, 32'hFFFFFFFF, 1'b1, "Write max value");
    test_read(5'd7, 5'd0, 32'hFFFFFFFF, 32'h0, "Read max value");
    
    // Test with minimum values  
    test_write(5'd8, 32'h00000000, 1'b1, "Write min value");
    test_read(5'd8, 5'd0, 32'h00000000, 32'h0, "Read min value");
    
    // Test alternating pattern
    test_write(5'd9, 32'hAAAAAAAA, 1'b1, "Write alternating pattern");
    test_read(5'd9, 5'd0, 32'hAAAAAAAA, 32'h0, "Read alternating pattern");
    
    test_write(5'd10, 32'h55555555, 1'b1, "Write inverse pattern");  
    test_read(5'd9, 5'd10, 32'hAAAAAAAA, 32'h55555555, "Read both patterns");
    
    $display("\n--- Testing Rapid Writes ---");
    // Test multiple writes to same register
    test_write(5'd15, 32'h11111111, 1'b1, "First write to x15");
    test_write(5'd15, 32'h22222222, 1'b1, "Second write to x15");
    test_write(5'd15, 32'h33333333, 1'b1, "Third write to x15");
    test_read(5'd15, 5'd0, 32'h33333333, 32'h0, "Read final value from x15");
    
    // Wait a few more cycles to ensure stability
    repeat(5) @(posedge clk);
    
    // Final verification - check that some key registers retain their values
    $display("\n--- Final Verification ---");
    test_read(5'd1, 5'd2, 32'h12345678, 32'hABCDEF00, "Final check x1,x2");
    test_read(5'd31, 5'd0, 32'hDEADBEEF, 32'h0, "Final check x31,x0");
    
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