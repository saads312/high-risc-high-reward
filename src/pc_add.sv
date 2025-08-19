module pc_add (
    input logic clk,
    input logic reset,
    input logic [31:0] pc,
    output logic [31:0] next_pc
);
always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        pc <= 32'b0; // Reset PC to 0
    end else begin
        next_pc <= pc + 4; // Update PC with the next value
    end
end