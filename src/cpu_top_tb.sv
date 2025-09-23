module cpu_top_tb;

logic clk;
logic reset;
logic [31:0] dbg_pc;
logic [31:0] dbg_instr;

// Instantiate the CPU
cpu_top dut (
    .clk(clk),
    .reset(reset),
    .dbg_pc(dbg_pc),
    .dbg_instr(dbg_instr)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10ns period
end

// Test stimulus
initial begin
    // Reset the processor
    reset = 1;
    #20;
    reset = 0;
    
    // Let the processor run for several cycles
    #200;
    
    // Display register file contents
    $display("=== Simulation Results ===");
    $display("PC: %h", dbg_pc);
    $display("Current Instruction: %h", dbg_instr);
    
    // Access register file for debugging
    $display("Register File Contents:");
    for (int i = 0; i < 10; i++) begin
        $display("x%0d: %h (%0d)", i, dut.u_rf.reg_array[i], dut.u_rf.reg_array[i]);
    end
    
    $finish;
end

// Monitor important signals
initial begin
    $monitor("Time: %0t | PC: %h | Instr: %h | Reset: %b", 
             $time, dbg_pc, dbg_instr, reset);
end

endmodule