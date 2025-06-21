`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2025 10:17:08 PM
// Design Name: 
// Module Name: EX_MEM
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


module EX_MEM(
    input         clk,
    input         rst,
    input  [31:0] ALURes_in,
    input  [31:0] StoreData_in,
    input  [4:0]  Rd_in,
    input         MemRead_in, MemWrite_in, RegWrite_in, MemtoReg_in,
    output reg [31:0] ALURes_out,
    output reg [31:0] StoreData_out,
    output reg [4:0]  Rd_out,
    output reg        MemRead_out, MemWrite_out, RegWrite_out, MemtoReg_out
);
  always @(posedge clk) begin
    if (rst) begin
      ALURes_out   <= 32'b0;
      StoreData_out<= 32'b0;
      Rd_out       <= 5'b0;
      MemRead_out  <= 1'b0;
      MemWrite_out <= 1'b0;
      RegWrite_out <= 1'b0;
      MemtoReg_out <= 1'b0;
    end else begin
      ALURes_out   <= ALURes_in;
      StoreData_out<= StoreData_in;
      Rd_out       <= Rd_in;
      MemRead_out  <= MemRead_in;
      MemWrite_out <= MemWrite_in;
      RegWrite_out <= RegWrite_in;
      MemtoReg_out <= MemtoReg_in;
    end
  end
endmodule
