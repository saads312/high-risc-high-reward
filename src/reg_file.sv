module reg_file (
    input clk,
    input rst,
    input [4:0] rs1, // bits 19:15
    input [4:0] rs2, // bits 24:20
    input [4:0] rd, // bits 11:7
    input [31:0] wdata, // data to write
    input wen, // write enable
    output logic [31:0] rdata1, // data from rs1
    output logic [31:0] rdata2 // data from rs2
);

logic [31:0] reg_array [31:0]; // 32 registers of 32 bits each

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        // Reset all registers to 0
        for (int i = 0; i < 32; i++) begin
            reg_array[i] <= 32'b0;
        end
    end else if (wen && rd != 5'b0) begin
        // Write data to the register specified by rd, except for x0
        reg_array[rd] <= wdata;
    end
end

always_comb begin
    rdata1 = reg_array[rs1];
    rdata2 = reg_array[rs2];
end
    
endmodule