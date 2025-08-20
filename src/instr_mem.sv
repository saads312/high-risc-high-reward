module instr_mem (
    input [31:0] pc,
    output logic [31:0] instruction 
);

logic [31:0] imem_array [1023:0];

initial begin
    $readmemh("instr_mem.hex", imem_array);
end

endmodule