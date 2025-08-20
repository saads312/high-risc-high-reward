module data_mem (
    input clk,
    input rst,
    input [31:0] addr,
    input [31:0] wdata,
    input wen,
    output logic [31:0] rdata
);

logic [31:0] dmem_array [1023:0];

always_ff @(posedge clk or posedge rst) begin
    if (rst)
        rdata <= 32'b0;
    else if (wen)
        dmem_array[addr[11:2]] <= wdata;
    else
        rdata <= dmem_array[addr[11:2]];
end

endmodule
