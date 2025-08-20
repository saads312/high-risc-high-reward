module ctrl (
    input [31:0] instruction,
    input logic zero,
    output logic PC_src,
    output logic [1:0] alu_op,
    output logic reg_write,
    output logic mem_write,
    output logic result_src,
    output logic alu_src,
    output logic imm_src
);

logic [6:0] opcode;

assign opcode = instruction[6:0];

always_comb begin
    // Default values
    PC_src = 0;
    alu_op = 2'b00;
    reg_write = 0;
    mem_write = 0;
    result_src = 0;
    alu_src = 0;
    imm_src = 0;

    case (opcode)
        7'b0110011: begin // R-type
            alu_op = 2'b10;
            reg_write = 1;
            alu_src = 0;
            result_src = 0;
        end
        7'b0010011,        // I-type ADDI etc.
        7'b0000011: begin // LW
            alu_op = 2'b00;
            alu_src = 1;
            reg_write = 1;
            result_src = (opcode == 7'b0000011); // Result comes from memory if LW
        end
        7'b0100011: begin // SW
            alu_op = 2'b00;
            alu_src = 1;
            mem_write = 1;
        end
        7'b1100011: begin // BEQ
            alu_op = 2'b01;
            alu_src = 0;
            PC_src = zero; // Use branch decision
        end
    endcase
end

endmodule
