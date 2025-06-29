`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2025 10:22:28 PM
// Design Name: 
// Module Name: IF_stage
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module IF_stage(
    input         clk,
    input         rst,
    input         stall,
    input         flush,
    input  [31:0] branch_target,
    input         branch_taken,
    input  [31:0] imem_q,       // BRAM data input
    output reg [31:0] PC,
    output reg [31:0] Instr,    // now registered here
    output     [31:0] PC_plus4
);

  assign PC_plus4 = PC + 4;

  // 1) PC update with proper async reset
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      PC <= 32'b0;
    end else if (!stall) begin
      if (branch_taken) 
        PC <= branch_target;
      else
        PC <= PC + 4;
    end
  end

  // 2) Instruction register: flush or rst → NOP, else capture imem_q
  always @(posedge clk or posedge rst) begin
    if (rst || flush) 
      Instr <= 32'b0;
    else if (!stall)
      Instr <= imem_q;
  end

endmodule

