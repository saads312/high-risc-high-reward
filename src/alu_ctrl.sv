module alu_ctrl (
    input logic op5,                 // opcode[5]
    input logic [2:0] funct3,        // instruction[14:12]
    input logic funct7,             // funct7[5] = instruction[30]
    input logic [1:0] alu_op,
    output logic [2:0] alu_ctrl
);

always_comb begin
    unique case (alu_op)
        2'b00: alu_ctrl = 3'b000; // LW, SW → ADD
        2'b01: alu_ctrl = 3'b001; // BEQ → SUB
        2'b10: begin // R-type
            unique case (funct3)
                3'b000: alu_ctrl = (funct7) ? 3'b001 : 3'b000; // SUB if funct7[5]=1, else ADD
                3'b010: alu_ctrl = 3'b101; // SLT
                3'b110: alu_ctrl = 3'b010; // OR
                3'b111: alu_ctrl = 3'b011; // AND
                default: alu_ctrl = 3'b000;
            endcase
        end
        default: alu_ctrl = 3'b000;
    endcase
end

endmodule