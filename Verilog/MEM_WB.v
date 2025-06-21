`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2025 10:19:59 PM
// Design Name: 
// Module Name: MEM_WB
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


module MEM_WB(
    input         clk,
    input         rst,
    input  [31:0] MemData_in,
    input  [31:0] ALURes_in,
    input  [4:0]  Rd_in,
    input         RegWrite_in, MemtoReg_in,
    output reg [31:0] MemData_out,
    output reg [31:0] ALURes_out,
    output reg [4:0]  Rd_out,
    output reg        RegWrite_out, MemtoReg_out
);
  always @(posedge clk) begin
    if (rst) begin
      MemData_out  <= 32'b0;
      ALURes_out   <= 32'b0;
      Rd_out       <= 5'b0;
      RegWrite_out <= 1'b0;
      MemtoReg_out <= 1'b0;
    end else begin
      MemData_out  <= MemData_in;
      ALURes_out   <= ALURes_in;
      Rd_out       <= Rd_in;
      RegWrite_out <= RegWrite_in;
      MemtoReg_out <= MemtoReg_in;
    end
  end
endmodule
