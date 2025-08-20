module # (
    parameter DATAW = 8
) alu (
    input [DATAW-1:0] i_dataa,
    input [DATAW-1:0] i_datab,
    input [3:0] i_op,
    output [2*DATAW-1:0] o_result,
    output logic carry_out,
    output logic zero,
    output logic overflow,
    output logic negative
);

logic [2*DATAW-1:0] result;

// operations to implement:
// add, sub, and, or, xor, sll, srl, sra, slt, sltu
always_comb begin : alu_result
    case (i_op)
        4'b0000: result = i_dataa + i_datab;  // ADD
        4'b0001: result = i_dataa - i_datab;  // SUB
        4'b0010: result = i_dataa & i_datab;  // AND
        4'b0011: result = i_dataa | i_datab;  // OR
        4'b0100: result = i_dataa ^ i_datab;  // XOR
        4'b0101: result = i_dataa << i_datab; // SLL
        4'b0110: result = i_dataa >> i_datab; // SRL
        4'b0111: result = $signed(i_dataa) >>> i_datab; // SRA
        4'b1000: result = ($signed(i_dataa) < $signed(i_datab)) ? 1 : 0; // SLT 
        4'b1001: result = (i_dataa < i_datab) ? 1 : 0; // SLTU
        default: result = {2*DATAW{1'b0}};  // Default case
    endcase

    negative = result[2*DATAW-1];
    zero = (result == 0);
    carry_out = (i_op == 4'b0000) ? (result[DATAW] != result[DATAW-1]) : 1'b0; // Carry out for ADD
    overflow  = (i_op == 4'b0000 || i_op == 4'b0001) ?
                ($signed(i_dataa[DATAW-1]) == $signed(i_datab[DATAW-1]) &&
                 $signed(result[DATAW-1]) != $signed(i_dataa[DATAW-1])) :
                1'b0;
end

assign o_result = result;

endmodule