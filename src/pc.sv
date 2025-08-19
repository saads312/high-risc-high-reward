module pc (
    input logic clk,
    input logic reset,
    input logic [31:0] next_pc,
    output logic [31:0] pc
)

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        pc <= 32'b0; // Reset PC to 0
    end else begin
        pc <= next_pc; // Update PC with the next value
    end
end

endmodule