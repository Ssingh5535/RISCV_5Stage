`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2025 09:04:09 PM
// Design Name: 
// Module Name: IF_ID
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

`timescale 1ns/1ps
module IF_ID(
  input         clk,
  input         rst,
  input         stall,
  input         flush,
  input  [31:0] PC_in,
  input  [31:0] Instr_in,
  output reg [31:0] PC_out,
  output reg [31:0] Instr_out
);

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      PC_out    <= 32'b0;
      Instr_out <= 32'b0;
    end else if (flush) begin
      PC_out    <= 32'b0;
      Instr_out <= 32'b0;
    end else if (!stall) begin
      PC_out    <= PC_in;
      Instr_out <= Instr_in;
    end
    // else stall: hold previous PC_out/Instr_out
  end

endmodule
