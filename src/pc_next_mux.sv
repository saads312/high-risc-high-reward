module pc_next_mux (
    input [31:0] pc_plus_4,
    input [31:0] pc_target,
    input logic pc_src,
    output logic [31:0] next_pc
);

always_comb begin
    if (!pc_src) begin
        next_pc = pc_target; // Use target address if pc_src is not asserted
    end else begin
        next_pc = pc_plus_4; // Otherwise, use the incremented PC value
    end
    
endmodule