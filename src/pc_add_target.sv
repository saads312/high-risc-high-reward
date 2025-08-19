module pc_add_target (
    input [31:0] pc,
    input [31:0] imm_ext,
    output logic [31:0] pc_target
);

always_comb begin
    pc_target = pc + imm_ext; // Calculate the target address by adding PC and immediate value
end