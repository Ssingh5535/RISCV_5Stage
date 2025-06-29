`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/20/2025 07:21:26 AM
// Design Name: 
// Module Name: hazard_unit
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


//module hazard_unit(
//    input        ID_EX_MemRead,
//    input  [4:0] ID_EX_Rd,
//    input  [4:0] IF_ID_Rs1,
//    input  [4:0] IF_ID_Rs2,
//    output       stall,
//    output       flush
//);
//  assign stall = ID_EX_MemRead &&
//                 ((ID_EX_Rd == IF_ID_Rs1) || (ID_EX_Rd == IF_ID_Rs2));
//  assign flush = stall;  // insert bubble on stall
//endmodule


//-----------------------------------------------------------------------------
// hazard_unit.v  -  catch exactly load→use hazards (MemtoReg), bubble EX for one cycle
//-----------------------------------------------------------------------------
module hazard_unit(
    input         ID_EX_MemtoReg,  // true if EX stage is a load writing back memory data
    input  [4:0]  ID_EX_Rd,        // destination register of that load
    input  [4:0]  IF_ID_Rs1,       // source regs for the *next* instruction
    input  [4:0]  IF_ID_Rs2,
    output        stall,           // freeze IF & ID
    output        flush            // bubble in EX
);

  // only hazard if rd!=x0, and the next insn actually needs that loaded value
  wire load_use = ID_EX_MemtoReg
                && (ID_EX_Rd != 5'd0)
                && ((ID_EX_Rd == IF_ID_Rs1) || (ID_EX_Rd == IF_ID_Rs2));

  assign stall = load_use;
  assign flush = load_use;

endmodule

