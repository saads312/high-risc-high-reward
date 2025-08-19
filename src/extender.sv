module extender (
    input [31:7] instr, // bits 31:7 of the instruction
    output logic [31:0] imm_ext // extended immediate value
);

always_comb begin
    case (instr[6:0]) // opcode
        7'b0010011, // I-type
        7'b0000011,
        7'b1100111: begin
            imm_ext = {{20{instr[31]}}, instr[31:20]};
        end
        7'b0100011: begin // S-type
            imm_ext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        end
        7'b1100011: begin // B-type
            imm_ext = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
        end
        7'b1101111: begin // J-type (JAL)
            imm_ext = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
        end
        7'b0110111, 7'b0010111: begin // U-type (LUI, AUIPC)
            imm_ext = {instr[31:12], 12'b0};
        end
        default: begin
            imm_ext = 32'b0; // Default case
        end
    endcase
end

endmodule