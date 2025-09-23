module extender_tb;

// Testbench signals
logic [31:7] instr;
logic [31:0] imm_ext;

// Test counters
int test_count = 0;
int pass_count = 0;
int fail_count = 0;

// Expected values
logic [31:0] expected_imm;

// Instantiate the extender
extender dut (
    .instr(instr),
    .imm_ext(imm_ext)
);

// Test task
task test_immediate_extension(
    input [31:0] full_instruction,
    input [31:0] exp_immediate,
    input string test_name
);
    instr = full_instruction[31:7];
    expected_imm = exp_immediate;
    
    #1; // Wait for combinational logic
    
    test_count++;
    
    if (imm_ext == expected_imm) begin
        $display("PASS: %s | Instruction=%h | Expected=%h, Got=%h", 
                 test_name, full_instruction, expected_imm, imm_ext);
        pass_count++;
    end else begin
        $display("FAIL: %s | Instruction=%h | Expected=%h, Got=%h", 
                 test_name, full_instruction, expected_imm, imm_ext);
        fail_count++;
    end
endtask

// Helper functions to create instructions
function [31:0] create_itype_instr(input [11:0] imm, input [4:0] rs1, rd, input [2:0] funct3, input [6:0] opcode);
    return {imm, rs1, funct3, rd, opcode};
endfunction

function [31:0] create_stype_instr(input [11:0] imm, input [4:0] rs2, rs1, input [2:0] funct3);
    return {imm[11:5], rs2, rs1, funct3, imm[4:0], 7'b0100011};
endfunction

function [31:0] create_btype_instr(input [12:0] imm, input [4:0] rs2, rs1, input [2:0] funct3);
    return {imm[12], imm[10:5], rs2, rs1, funct3, imm[4:1], imm[11], 7'b1100011};
endfunction

function [31:0] create_utype_instr(input [19:0] imm, input [4:0] rd, input [6:0] opcode);
    return {imm, rd, opcode};
endfunction

function [31:0] create_jtype_instr(input [20:0] imm, input [4:0] rd);
    return {imm[20], imm[10:1], imm[11], imm[19:12], rd, 7'b1101111};
endfunction

// Sign extension helper
function [31:0] sign_extend_12(input [11:0] val);
    return {{20{val[11]}}, val};
endfunction

function [31:0] sign_extend_13(input [12:0] val);
    return {{19{val[12]}}, val};
endfunction

function [31:0] sign_extend_21(input [20:0] val);
    return {{11{val[20]}}, val};
endfunction

// Main test
initial begin
    $display("=== Extender Testbench Starting ===");
    
    // Test I-type instructions (ADDI, SLTI, etc.)
    $display("\n--- Testing I-type Instructions ---");
    
    // ADDI x1, x2, 100
    test_immediate_extension(create_itype_instr(12'd100, 5'd2, 5'd1, 3'b000, 7'b0010011),
                           sign_extend_12(12'd100), "ADDI positive immediate");
    
    // ADDI x3, x4, -50
    test_immediate_extension(create_itype_instr(-12'd50, 5'd4, 5'd3, 3'b000, 7'b0010011),
                           sign_extend_12(-12'd50), "ADDI negative immediate");
    
    // SLTI x5, x6, 2047 (max positive 12-bit)
    test_immediate_extension(create_itype_instr(12'h7FF, 5'd6, 5'd5, 3'b010, 7'b0010011),
                           sign_extend_12(12'h7FF), "SLTI max positive");
    
    // SLTI x7, x8, -2048 (min negative 12-bit)
    test_immediate_extension(create_itype_instr(-12'd2048, 5'd8, 5'd7, 3'b010, 7'b0010011),
                           sign_extend_12(-12'd2048), "SLTI max negative");
    
    // ANDI x9, x10, 255
    test_immediate_extension(create_itype_instr(12'd255, 5'd10, 5'd9, 3'b111, 7'b0010011),
                           sign_extend_12(12'd255), "ANDI immediate");
    
    // Test Load instructions (same format as I-type)
    $display("\n--- Testing Load Instructions ---");
    
    // LW x1, 4(x2)
    test_immediate_extension(create_itype_instr(12'd4, 5'd2, 5'd1, 3'b010, 7'b0000011),
                           sign_extend_12(12'd4), "LW positive offset");
    
    // LW x3, -8(x4)
    test_immediate_extension(create_itype_instr(-12'd8, 5'd4, 5'd3, 3'b010, 7'b0000011),
                           sign_extend_12(-12'd8), "LW negative offset");
    
    // LW x5, 0(x6)
    test_immediate_extension(create_itype_instr(12'd0, 5'd6, 5'd5, 3'b010, 7'b0000011),
                           32'd0, "LW zero offset");
    
    // Test JALR instruction (also I-type format)
    $display("\n--- Testing JALR Instructions ---");
    
    // JALR x1, x2, 12
    test_immediate_extension(create_itype_instr(12'd12, 5'd2, 5'd1, 3'b000, 7'b1100111),
                           sign_extend_12(12'd12), "JALR positive offset");
    
    // JALR x3, x4, -16
    test_immediate_extension(create_itype_instr(-12'd16, 5'd4, 5'd3, 3'b000, 7'b1100111),
                           sign_extend_12(-12'd16), "JALR negative offset");
    
    // Test S-type instructions (Store)
    $display("\n--- Testing S-type Instructions ---");
    
    // SW x3, 8(x4)
    test_immediate_extension(create_stype_instr(12'd8, 5'd3, 5'd4, 3'b010),
                           sign_extend_12(12'd8), "SW positive offset");
    
    // SW x5, -12(x6)
    test_immediate_extension(create_stype_instr(-12'd12, 5'd5, 5'd6, 3'b010),
                           sign_extend_12(-12'd12), "SW negative offset");
    
    // SW x7, 0(x8)
    test_immediate_extension(create_stype_instr(12'd0, 5'd7, 5'd8, 3'b010),
                           32'd0, "SW zero offset");
    
    // SW x9, 2047(x10) (max positive)
    test_immediate_extension(create_stype_instr(12'h7FF, 5'd9, 5'd10, 3'b010),
                           sign_extend_12(12'h7FF), "SW max positive");
    
    // SW x11, -2048(x12) (max negative) 
    test_immediate_extension(create_stype_instr(-12'd2048, 5'd11, 5'd12, 3'b010),
                           sign_extend_12(-12'd2048), "SW max negative");
    
    // Test B-type instructions (Branch)
    $display("\n--- Testing B-type Instructions ---");
    
    // BEQ x1, x2, 16
    test_immediate_extension(create_btype_instr(13'd16, 5'd2, 5'd1, 3'b000),
                           sign_extend_13(13'd16), "BEQ positive offset");
    
    // BEQ x3, x4, -12
    test_immediate_extension(create_btype_instr(-13'd12, 5'd4, 5'd3, 3'b000),
                           sign_extend_13(-13'd12), "BEQ negative offset");
    
    // BEQ x5, x6, 0
    test_immediate_extension(create_btype_instr(13'd0, 5'd6, 5'd5, 3'b000),
                           32'd0, "BEQ zero offset");
    
    // BEQ x7, x8, 4094 (max positive, must be even)
    test_immediate_extension(create_btype_instr(13'd4094, 5'd8, 5'd7, 3'b000),
                           sign_extend_13(13'd4094), "BEQ max positive");
    
    // BEQ x9, x10, -4096 (max negative)
    test_immediate_extension(create_btype_instr(-13'd4096, 5'd10, 5'd9, 3'b000),
                           sign_extend_13(-13'd4096), "BEQ max negative");
    
    // Test U-type instructions (LUI, AUIPC)
    $display("\n--- Testing U-type Instructions ---");
    
    // LUI x1, 0x12345
    test_immediate_extension(create_utype_instr(20'h12345, 5'd1, 7'b0110111),
                           {20'h12345, 12'h000}, "LUI positive");
    
    // LUI x2, 0xFFFFF (all 1s in upper 20 bits)
    test_immediate_extension(create_utype_instr(20'hFFFFF, 5'd2, 7'b0110111),
                           {20'hFFFFF, 12'h000}, "LUI all 1s");
    
    // LUI x3, 0x00000 (all 0s)
    test_immediate_extension(create_utype_instr(20'h00000, 5'd3, 7'b0110111),
                           32'h00000000, "LUI all 0s");
    
    // AUIPC x4, 0xABCDE
    test_immediate_extension(create_utype_instr(20'hABCDE, 5'd4, 7'b0010111),
                           {20'hABCDE, 12'h000}, "AUIPC");
    
    // Test J-type instructions (JAL)
    $display("\n--- Testing J-type Instructions ---");
    
    // JAL x1, 1048 (positive jump)
    test_immediate_extension(create_jtype_instr(21'd1048, 5'd1),
                           sign_extend_21(21'd1048), "JAL positive");
    
    // JAL x2, -2048 (negative jump)
    test_immediate_extension(create_jtype_instr(-21'd2048, 5'd2),
                           sign_extend_21(-21'd2048), "JAL negative");
    
    // JAL x3, 0 (zero jump - infinite loop)
    test_immediate_extension(create_jtype_instr(21'd0, 5'd3),
                           32'd0, "JAL zero");
    
    // JAL x4, 1048574 (max positive)
    test_immediate_extension(create_jtype_instr(21'h0FFFFE, 5'd4),
                           sign_extend_21(21'h0FFFFE), "JAL max positive");
    
    // JAL x5, -1048576 (max negative)
    test_immediate_extension(create_jtype_instr(-21'd1048576, 5'd5),
                           sign_extend_21(-21'd1048576), "JAL max negative");
    
    // Test edge cases and unknown opcodes
    $display("\n--- Testing Edge Cases ---");
    
    // Unknown opcode should default to zero
    test_immediate_extension(32'h12345678, 32'h00000000, "Unknown opcode");
    
    // All zeros
    test_immediate_extension(32'h00000000, 32'h00000000, "All zeros");
    
    // All ones - should be treated as unknown opcode
    test_immediate_extension(32'hFFFFFFFF, 32'h00000000, "All ones");
    
    // Test specific bit patterns
    $display("\n--- Testing Bit Patterns ---");
    
    // I-type with alternating bits in immediate
    test_immediate_extension(create_itype_instr(12'hAAA, 5'd1, 5'd2, 3'b000, 7'b0010011),
                           sign_extend_12(12'hAAA), "I-type alternating bits");
    
    // S-type with alternating bits
    test_immediate_extension(create_stype_instr(12'h555, 5'd3, 5'd4, 3'b010),
                           sign_extend_12(12'h555), "S-type alternating bits");
    
    // B-type with specific pattern
    test_immediate_extension(create_btype_instr(13'h1554, 5'd5, 5'd6, 3'b000),
                           sign_extend_13(13'h1554), "B-type pattern");
    
    // U-type with alternating pattern
    test_immediate_extension(create_utype_instr(20'hAAAAA, 5'd7, 7'b0110111),
                           {20'hAAAAA, 12'h000}, "U-type alternating");
    
    // J-type with specific pattern
    test_immediate_extension(create_jtype_instr(21'h155554, 5'd8),
                           sign_extend_21(21'h155554), "J-type pattern");
    
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