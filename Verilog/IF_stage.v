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
    output reg [31:0] PC,
    output [31:0] Instr,
    output [31:0] PC_plus4
);
  // PC register
  wire [31:0] next_pc = (branch_taken) ? branch_target : PC + 4;
  always @(posedge clk) begin
    if (rst)       PC <= 32'b0;
    else if (!stall) PC <= next_pc;
  end

  // Instruction memory (simple ROM)
  reg [31:0] imem [0:1023];
  assign Instr   = (rst || flush) ? 32'b0 : imem[PC[11:2]];
  assign PC_plus4 = PC + 4;
endmodule
