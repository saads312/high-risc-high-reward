// module ctrl (
//     input [2:0] funct3,
//     input [6:0] funct7,
//     input [6:0] opcode,
//     input zero,
//     output pc_src,
//     output result_src,
//     output mem_write,
//     output [1:0] alu_op,
//     output alu_src,
//     output [1:0] imm_src,
//     output reg_write
// );

// always_comb begin : ctrl_signals
//     // Default values
//     pc_src = 0;
//     result_src = 0;
//     mem_write = 0;
//     alu_op = 2'b00;
//     alu_src = 0;
//     imm_src = 2'b00;
//     reg_write = 0;

//     case (opcode)
//         7'b0110011: begin // R-type
//             alu_op = 2'b01;
//             alu_src = 0;
//             reg_write = 1;
//         end
//         7'b0010011: begin // I-type (e.g. ADDI)
//             alu_op = 2'b10;
//             alu_src = 1;
//             reg_write = 1;
//             imm_src = 2'b00;
//         end
//         7'b0000011: begin // Load (e.g. LW)
//             alu_op = 2'b00;
//             alu_src = 1;
//             reg_write = 1;
//             result_src = 1;
//             imm_src = 2'b00;
//         end
//         7'b0100011: begin // Store (e.g. SW)
//             alu_op = 2'b00;
//             alu_src = 1;
//             mem_write = 1;
//             imm_src = 2'b01;
//         end
//         7'b1100011: begin // Branch (e.g. BEQ)
//             alu_op = 2'b01;
//             alu_src = 0;
//             imm_src = 2'b10;
//             if (funct3 == 3'b000) pc_src = zero;       // BEQ
//             else if (funct3 == 3'b001) pc_src = ~zero; // BNE
//         end
//         7'b1101111: begin // JAL
//             pc_src = 1;
//             result_src = 1;
//             reg_write = 1;
//             imm_src = 2'b11;
//         end
//         7'b1100111: begin // JALR
//             pc_src = 1;
//             result_src = 1;
//             alu_src = 1;
//             reg_write = 1;
//             imm_src = 2'b00;
//         end
//     default: begin
//         pc_src = 0;
//         result_src = 0;
//         mem_write = 0;
//         alu_op = 2'b00;
//         alu_src = 0;
//         imm_src = 2'b00;
//         reg_write = 0;
//     end
//     endcase
// end

// endmodule