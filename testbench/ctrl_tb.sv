module ctrl_tb;

// Testbench signals
logic [31:0] instruction;
logic zero;
logic PC_src;
logic [1:0] alu_op;
logic reg_write;
logic mem_write;
logic result_src;
logic alu_src;
logic [1:0] imm_src;

// Test counters
int test_count = 0;
int pass_count = 0;
int fail_count = 0;

// Instantiate the control unit
ctrl dut (
    .instruction(instruction),
    .zero(zero),
    .PC_src(PC_src),
    .alu_op(alu_op),
    .reg_write(reg_write),
    .mem_write(mem_write),
    .result_src(result_src),
    .alu_src(alu_src),
    .imm_src(imm_src)
);

// Test task
task test_control_signals(
    input [31:0] instr,
    input zero_flag,
    input exp_pc_src,
    input [1:0] exp_alu_op,
    input exp_reg_write,
    input exp_mem_write,
    input exp_result_src,
    input exp_alu_src,
    input [1:0] exp_imm_src,
    input string instr_name
);
    instruction = instr;
    zero = zero_flag;
    
    #1; // Wait for combinational logic
    
    test_count++;
    
    if (PC_src == exp_pc_src && 
        alu_op == exp_alu_op && 
        reg_write == exp_reg_write &&
        mem_write == exp_mem_write &&
        result_src == exp_result_src &&
        alu_src == exp_alu_src &&
        imm_src == exp_imm_src) begin
        
        $display("PASS: %s | PC_src=%b, ALU_op=%b, RegW=%b, MemW=%b, ResultSrc=%b, ALUSrc=%b, ImmSrc=%b", 
                 instr_name, PC_src, alu_op, reg_write, mem_write, result_src, alu_src, imm_src);
        pass_count++;
    end else begin
        $display("FAIL: %s", instr_name);
        $display("  Expected: PC_src=%b, ALU_op=%b, RegW=%b, MemW=%b, ResultSrc=%b, ALUSrc=%b, ImmSrc=%b", 
                 exp_pc_src, exp_alu_op, exp_reg_write, exp_mem_write, exp_result_src, exp_alu_src, exp_imm_src);
        $display("  Got:      PC_src=%b, ALU_op=%b, RegW=%b, MemW=%b, ResultSrc=%b, ALUSrc=%b, ImmSrc=%b", 
                 PC_src, alu_op, reg_write, mem_write, result_src, alu_src, imm_src);
        fail_count++;
    end
endtask

// Helper function to create instruction
function [31:0] create_rtype_instr(input [4:0] rs2, rs1, rd, input [2:0] funct3, input [6:0] funct7);
    return {funct7, rs2, rs1, funct3, rd, 7'b0110011};
endfunction

function [31:0] create_itype_instr(input [11:0] imm, input [4:0] rs1, rd, input [2:0] funct3, input [6:0] opcode);
    return {imm, rs1, funct3, rd, opcode};
endfunction

function [31:0] create_stype_instr(input [11:0] imm, input [4:0] rs2, rs1, input [2:0] funct3);
    return {imm[11:5], rs2, rs1, funct3, imm[4:0], 7'b0100011};
endfunction

function [31:0] create_btype_instr(input [12:0] imm, input [4:0] rs2, rs1, input [2:0] funct3);
    return {imm[12], imm[10:5], rs2, rs1, funct3, imm[4:1], imm[11], 7'b1100011};
endfunction

// Main test
initial begin
    $display("=== Control Unit Testbench Starting ===");
    
    // Test R-type instructions
    $display("\n--- Testing R-type Instructions ---");
    // ADD x1, x2, x3
    test_control_signals(create_rtype_instr(5'd3, 5'd2, 5'd1, 3'b000, 7'b0000000), 1'b0,
                        1'b0, 2'b10, 1'b1, 1'b0, 1'b0, 1'b0, 2'b00, "ADD");
    
    // SUB x4, x5, x6  
    test_control_signals(create_rtype_instr(5'd6, 5'd5, 5'd4, 3'b000, 7'b0100000), 1'b0,
                        1'b0, 2'b10, 1'b1, 1'b0, 1'b0, 1'b0, 2'b00, "SUB");
    
    // AND x7, x8, x9
    test_control_signals(create_rtype_instr(5'd9, 5'd8, 5'd7, 3'b111, 7'b0000000), 1'b0,
                        1'b0, 2'b10, 1'b1, 1'b0, 1'b0, 1'b0, 2'b00, "AND");
    
    // OR x10, x11, x12
    test_control_signals(create_rtype_instr(5'd12, 5'd11, 5'd10, 3'b110, 7'b0000000), 1'b0,
                        1'b0, 2'b10, 1'b1, 1'b0, 1'b0, 1'b0, 2'b00, "OR");
    
    // SLT x13, x14, x15
    test_control_signals(create_rtype_instr(5'd15, 5'd14, 5'd13, 3'b010, 7'b0000000), 1'b0,
                        1'b0, 2'b10, 1'b1, 1'b0, 1'b0, 1'b0, 2'b00, "SLT");
    
    // Test I-type ALU instructions  
    $display("\n--- Testing I-type ALU Instructions ---");
    // ADDI x1, x2, 100
    test_control_signals(create_itype_instr(12'd100, 5'd2, 5'd1, 3'b000, 7'b0010011), 1'b0,
                        1'b0, 2'b10, 1'b1, 1'b0, 1'b0, 1'b1, 2'b00, "ADDI");
    
    // SLTI x3, x4, -50
    test_control_signals(create_itype_instr(-12'd50, 5'd4, 5'd3, 3'b010, 7'b0010011), 1'b0,
                        1'b0, 2'b10, 1'b1, 1'b0, 1'b0, 1'b1, 2'b00, "SLTI");
    
    // ANDI x5, x6, 255
    test_control_signals(create_itype_instr(12'd255, 5'd6, 5'd5, 3'b111, 7'b0010011), 1'b0,
                        1'b0, 2'b10, 1'b1, 1'b0, 1'b0, 1'b1, 2'b00, "ANDI");
    
    // ORI x7, x8, 128
    test_control_signals(create_itype_instr(12'd128, 5'd8, 5'd7, 3'b110, 7'b0010011), 1'b0,
                        1'b0, 2'b10, 1'b1, 1'b0, 1'b0, 1'b1, 2'b00, "ORI");
    
    // Test Load instructions
    $display("\n--- Testing Load Instructions ---");
    // LW x1, 4(x2)
    test_control_signals(create_itype_instr(12'd4, 5'd2, 5'd1, 3'b010, 7'b0000011), 1'b0,
                        1'b0, 2'b00, 1'b1, 1'b0, 1'b1, 1'b1, 2'b00, "LW");
    
    // LW x10, -8(x15)  
    test_control_signals(create_itype_instr(-12'd8, 5'd15, 5'd10, 3'b010, 7'b0000011), 1'b0,
                        1'b0, 2'b00, 1'b1, 1'b0, 1'b1, 1'b1, 2'b00, "LW negative offset");
    
    // Test Store instructions
    $display("\n--- Testing Store Instructions ---");
    // SW x3, 8(x4)
    test_control_signals(create_stype_instr(12'd8, 5'd3, 5'd4, 3'b010), 1'b0,
                        1'b0, 2'b00, 1'b0, 1'b1, 1'b0, 1'b1, 2'b01, "SW");
    
    // SW x20, -16(x21)
    test_control_signals(create_stype_instr(-12'd16, 5'd20, 5'd21, 3'b010), 1'b0,
                        1'b0, 2'b00, 1'b0, 1'b1, 1'b0, 1'b1, 2'b01, "SW negative offset");
    
    // Test Branch instructions
    $display("\n--- Testing Branch Instructions ---");
    // BEQ x1, x2, 16 (zero flag = 0, branch not taken)
    test_control_signals(create_btype_instr(13'd16, 5'd2, 5'd1, 3'b000), 1'b0,
                        1'b0, 2'b01, 1'b0, 1'b0, 1'b0, 1'b0, 2'b10, "BEQ not taken");
    
    // BEQ x1, x2, 16 (zero flag = 1, branch taken)
    test_control_signals(create_btype_instr(13'd16, 5'd2, 5'd1, 3'b000), 1'b1,
                        1'b1, 2'b01, 1'b0, 1'b0, 1'b0, 1'b0, 2'b10, "BEQ taken");
    
    // BEQ x5, x6, -12 (zero flag = 0, branch not taken)
    test_control_signals(create_btype_instr(-13'd12, 5'd6, 5'd5, 3'b000), 1'b0,
                        1'b0, 2'b01, 1'b0, 1'b0, 1'b0, 1'b0, 2'b10, "BEQ backward not taken");
    
    // BEQ x5, x6, -12 (zero flag = 1, branch taken)
    test_control_signals(create_btype_instr(-13'd12, 5'd6, 5'd5, 3'b000), 1'b1,
                        1'b1, 2'b01, 1'b0, 1'b0, 1'b0, 1'b0, 2'b10, "BEQ backward taken");
    
    // Test unknown instruction (should use default values)
    $display("\n--- Testing Unknown Instructions ---");
    test_control_signals(32'h12345678, 1'b0,
                        1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, "Unknown instruction");
    
    // Test edge cases
    $display("\n--- Testing Edge Cases ---");
    // All zeros instruction
    test_control_signals(32'h00000000, 1'b0,
                        1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, "All zeros");
    
    // All ones instruction  
    test_control_signals(32'hFFFFFFFF, 1'b0,
                        1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, "All ones");
    
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