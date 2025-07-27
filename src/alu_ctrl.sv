module alu_ctrl (
    input [1:0] alu_op,
    input [2:0] funct3,
    input [6:0] funct7,
    output logic [3:0] alu_sel
);

always_comb begin
    case (alu_op)
        2'b00: begin // Load/Store or immediate arithmetic
            case (funct3)
                3'b000: alu_sel = 4'b0000; // ADD
                3'b100: alu_sel = 4'b0010; // AND
                3'b110: alu_sel = 4'b0011; // OR
                3'b111: alu_sel = 4'b0100; // XOR
                default: alu_sel = 4'b0000; // Default to ADD
            endcase
        end
        2'b01: begin // R-type
            case (funct3)
                3'b000: alu_sel = (funct7[5] == 1'b1) ? 4'b0001 : 4'b0000; // SUB or ADD
                3'b001: alu_sel = 4'b0101; // SLL
                3'b010: alu_sel = 4'b1000; // SLT
                3'b011: alu_sel = 4'b1001; // SLTU
                3'b100: alu_sel = 4'b0010; // AND
                3'b101: alu_sel = (funct7[5] == 1'b1) ? 4'b0111 : 4'b0110; // SRA or SRL
                3'b110: alu_sel = 4'b0011; // OR
                3'b111: alu_sel = 4'b0100; // XOR
                default: alu_sel = 4'b0000;
            endcase
        end
        default: alu_sel = 4'b0000;
    endcase
end

endmodule
