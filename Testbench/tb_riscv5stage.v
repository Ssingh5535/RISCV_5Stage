`timescale 1ns/1ps

//-----------------------------------------------------------------------------  
// Testbench for 5-Stage RV32I RISC-V Pipeline (riscv5stage_top)
//-----------------------------------------------------------------------------  
module tb_riscv5stage;

  // Clock and reset
  reg        clk;
  reg        rst;

  // Debug output
  wire       debug_led;

  // Instantiate the DUT
  riscv5stage_top dut (
    .clk       (clk),
    .rst       (rst),
    .debug_led (debug_led)
  );

  // Clock generation: 10ns period (100MHz)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Reset sequence: assert for two cycles
  initial begin
    rst = 1;
    #20;
    rst = 0;
  end

  // Memory initialization
  initial begin
    // Load instruction memory
    $readmemh("imem.hex", dut.u_IF_stage.imem);
    // Load data memory
    $readmemh("dmem.hex", dut.u_MEM_stage.dmem);
  end

  // Simulation control: run for 3000 ns then finish
  initial begin
    #3000;
    $display("Simulation complete.");
    $finish;
  end

  // Monitoring: display PC, fetched instruction, and debug_led each cycle
  initial begin
    $display("Time(ns)  PC       Instr     LED");
    $monitor("%0dns: %h %h %b", 
             $time, 
             dut.u_IF_stage.PC, 
             dut.u_IF_stage.Instr, 
             debug_led);
  end

  // ------------------------------------------------------------
  // Additional monitoring: Forwarding unit signals around ADD
  // ------------------------------------------------------------
  // We monitor:
  // - ID/EX source registers: EX_Rs1, EX_Rs2
  // - EX/MEM write signals: MEM_RegWrite, MEM_Rd
  // - MEM/WB write signals: WB_en, WB_addr
  // - Forwarding unit outputs: forwardA, forwardB
  //
  // This lets you see for each cycle whether forwarding should occur.
  initial begin
    // Header
    $display("\nTime   EX_Rs1 EX_Rs2 EX_MEM_RegWrite EX_MEM_Rd MEM_WB_RegWrite MEM_WB_Rd forwardA forwardB");
    // Monitor continuously
    $monitor("%0t   %0d     %0d        %b             %0d        %b             %0d       %b        %b",
             $time,
             dut.EX_Rs1,                // ID/EX Rs1
             dut.EX_Rs2,                // ID/EX Rs2
             dut.MEM_RegWrite,          // EX/MEM.RegWrite_out
             dut.MEM_Rd,                // EX/MEM.Rd_out
             dut.WB_en,                 // MEM/WB.RegWrite_out
             dut.WB_addr,               // MEM/WB.Rd_out
             dut.u_forward.forwardA,    // forwarding decision A
             dut.u_forward.forwardB     // forwarding decision B
    );
  end

endmodule
