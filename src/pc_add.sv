module pc_add (
    input logic [31:0] pc,
    output logic [31:0] pc_plus4
);

assign pc_plus4 = pc + 4;
