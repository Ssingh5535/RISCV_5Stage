`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2025 10:06:40 PM
// Design Name: 
// Module Name: ID_EX
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


module ID_EX(
    input         clk,
    input         rst,
    input         stall,
    input         flush,
    input  [31:0] PC_in,
    input  [31:0] RegData1_in,
    input  [31:0] RegData2_in,
    input  [31:0] Imm_in,
    input  [4:0]  Rs1_in, Rs2_in, Rd_in,
    input  [6:0]  Opcode_in,
    input  [2:0]  Funct3_in,
    input  [6:0]  Funct7_in,
    input         MemRead_in, MemWrite_in, RegWrite_in, MemtoReg_in,
    input  [3:0]  ALUOp_in,
    output reg [31:0] PC_out,
    output reg [31:0] RegData1_out,
    output reg [31:0] RegData2_out,
    output reg [31:0] Imm_out,
    output reg [4:0]  Rs1_out, Rs2_out, Rd_out,
    output reg [6:0]  Opcode_out,
    output reg [2:0]  Funct3_out,
    output reg [6:0]  Funct7_out,
    output reg        MemRead_out, MemWrite_out, RegWrite_out, MemtoReg_out,
    output reg [3:0]  ALUOp_out
);
  always @(posedge clk) begin
    if (rst) begin
      PC_out        <= 32'b0;
      RegData1_out  <= 32'b0;
      RegData2_out  <= 32'b0;
      Imm_out       <= 32'b0;
      Rs1_out       <= 5'b0;
      Rs2_out       <= 5'b0;
      Rd_out        <= 5'b0;
      Opcode_out    <= 7'b0;
      Funct3_out    <= 3'b0;
      Funct7_out    <= 7'b0;
      MemRead_out   <= 1'b0;
      MemWrite_out  <= 1'b0;
      RegWrite_out  <= 1'b0;
      MemtoReg_out  <= 1'b0;
      ALUOp_out     <= 4'b0;
    end else if (flush) begin
      // Flush: insert bubble by clearing all outputs
      PC_out        <= 32'b0;
      RegData1_out  <= 32'b0;
      RegData2_out  <= 32'b0;
      Imm_out       <= 32'b0;
      Rs1_out       <= 5'b0;
      Rs2_out       <= 5'b0;
      Rd_out        <= 5'b0;
      Opcode_out    <= 7'b0;
      Funct3_out    <= 3'b0;
      Funct7_out    <= 7'b0;
      MemRead_out   <= 1'b0;
      MemWrite_out  <= 1'b0;
      RegWrite_out  <= 1'b0;
      MemtoReg_out  <= 1'b0;
      ALUOp_out     <= 4'b0;
    end else if (!stall) begin
      // Normal operation: latch inputs
      PC_out        <= PC_in;
      RegData1_out  <= RegData1_in;
      RegData2_out  <= RegData2_in;
      Imm_out       <= Imm_in;
      Rs1_out       <= Rs1_in;
      Rs2_out       <= Rs2_in;
      Rd_out        <= Rd_in;
      Opcode_out    <= Opcode_in;
      Funct3_out    <= Funct3_in;
      Funct7_out    <= Funct7_in;
      MemRead_out   <= MemRead_in;
      MemWrite_out  <= MemWrite_in;
      RegWrite_out  <= RegWrite_in;
      MemtoReg_out  <= MemtoReg_in;
      ALUOp_out     <= ALUOp_in;
    end
  end
endmodule
