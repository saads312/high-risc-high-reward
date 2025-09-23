module cpu_top (
    input logic clk,
    input logic reset,

    // optional debug
    output logic [31:0] dbg_pc,
    output logic [31:0] dbg_instr
);

  // ---------- IF ----------
  logic [31:0] pc_cur, pc_plus4, pc_target, pc_next;
  logic [31:0] instr;

  pc           u_pc        (.clk(clk), .reset(reset), .next_pc(pc_next), .pc(pc_cur));
  pc_add       u_pc_add    (.pc(pc_cur), .pc_plus4(pc_plus4));
  instr_mem    u_imem      (.pc(pc_cur), .instruction(instr));

  // ---------- ID ----------
  // fields
  logic [6:0]  opcode   = instr[6:0];
  logic [2:0]  funct3   = instr[14:12];
  logic        funct7b5 = instr[30];         // funct7[5]
  logic        op5      = opcode[5];         // if you need it
  logic [4:0]  rs1      = instr[19:15];
  logic [4:0]  rs2      = instr[24:20];
  logic [4:0]  rd       = instr[11:7];

  // immediate
  logic [31:0] imm_ext;
  extender     u_imm     (.instr(instr[31:7]), .imm_ext(imm_ext));

  // register file
  logic [31:0] rs1_data, rs2_data, write_back_data;
  logic        reg_write;

  reg_file u_rf (
    .clk(clk), .rst(reset),
    .rs1(rs1), .rs2(rs2), .rd(rd),
    .wdata(write_back_data),
    .wen(reg_write),
    .rdata1(rs1_data), .rdata2(rs2_data)
  );

  // ---------- control ----------
  logic        pc_src, mem_write, result_src, alu_src;
  logic [1:0]  imm_src;   // keep this 2 bits, per your diagram
  logic [1:0]  alu_op;
  logic [2:0]  alu_ctrl3;

  // main decoder (you’ll fill this module)
  ctrl u_ctrl (
    .instruction(instr),
    .zero(alu_zero),
    .PC_src(pc_src),
    .alu_op(alu_op),
    .reg_write(reg_write),
    .mem_write(mem_write),
    .result_src(result_src),
    .alu_src(alu_src),
    .imm_src(imm_src)       // not used in this simple top, but keep it
  );

  // alu decoder (you wrote this)
  alu_ctrl u_alud (
    .op5(op5),
    .funct3(funct3),
    .funct7(funct7b5),
    .alu_op(alu_op),
    .alu_ctrl(alu_ctrl3)
  );

  // map your 3-bit ALUControl into your ALU's 4-bit i_op
  function automatic logic [3:0] map_alu_op (input logic [2:0] ac);
    case (ac)
      3'b000: map_alu_op = 4'b0000; // add
      3'b001: map_alu_op = 4'b0001; // sub
      3'b010: map_alu_op = 4'b0011; // or
      3'b011: map_alu_op = 4'b0010; // and
      3'b101: map_alu_op = 4'b1000; // slt (signed)
      default:map_alu_op = 4'b0000;
    endcase
  endfunction

  // ---------- EX ----------
  // ALU src mux (rs2 vs immediate)
  logic [31:0] alu_in_b = alu_src ? imm_ext : rs2_data;

  logic [63:0] alu_wide_result;
  logic        alu_carry, alu_zero, alu_overflow, alu_neg;
  logic        carry;

  // your ALU uses parameter DATAW; set to 32
  alu #(.DATAW(32)) u_alu (
    .i_dataa(rs1_data),
    .i_datab(alu_in_b),
    .i_op   (map_alu_op(alu_ctrl3)),
    .o_result(alu_wide_result),
    .carry_out(carry), .zero(alu_zero),
    .overflow(alu_overflow), .negative(alu_neg)
  );

  // Use lower 32 bits for the datapath
  logic [31:0] alu_result = alu_wide_result[31:0];

  // branch target (PC + imm)
  pc_add_target u_pctgt (.pc(pc_cur), .imm_ext(imm_ext), .pc_target(pc_target));

  // next PC
  pc_next_mux u_pcs (.pc_plus4(pc_plus4), .pc_target(pc_target), .pc_src(pc_src), .next_pc(pc_next));

  // ---------- MEM ----------
  logic [31:0] dmem_rdata;
  data_mem u_dmem (
    .clk(clk), .rst(reset),
    .addr (alu_result),
    .wdata(rs2_data),
    .wen  (mem_write),
    .rdata(dmem_rdata)
  );

  // ---------- WB ----------
  // ResultSrc: 0 -> ALU result, 1 -> memory read
  assign write_back_data = result_src ? dmem_rdata : alu_result;

  // debug taps
  assign dbg_pc    = pc_cur;
  assign dbg_instr = instr;

endmodule
