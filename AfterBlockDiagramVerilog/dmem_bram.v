`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2025 05:48:26 PM
// Design Name: 
// Module Name: dmem_bram
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


//------------------------------------------------------------------------------
// dmem_bram.v: simple synchronous RAM, 32-bit words, depth = 2^ADDR_BITS
//------------------------------------------------------------------------------
//module dmem_bram #(
//  parameter ADDR_BITS = 10
//)(
//  input               clka,
//  input               ena,
//  input  [3:0]        wea,
//  input  [ADDR_BITS-1:0] addra,
//  input  [31:0]       dina,
//  output reg [31:0]   douta
//);

//  reg [31:0] mem [0:(1<<ADDR_BITS)-1];

//  // optionally preload, or leave empty:
//  initial begin
//    if ($test$plusargs("load_dmem")) begin
//      $readmemh("dmem.hex", mem);
//    end
//  end

//  always @(posedge clka) begin
//    if (ena) begin
//      if (|wea) begin
//        // byte enables:
//        if (wea[0]) mem[addra][ 7: 0] <= dina[ 7: 0];
//        if (wea[1]) mem[addra][15: 8] <= dina[15: 8];
//        if (wea[2]) mem[addra][23:16] <= dina[23:16];
//        if (wea[3]) mem[addra][31:24] <= dina[31:24];
//      end
//      douta <= mem[addra];
//    end
//  end

//endmodule



module dmem_bram (
  input             clka,
  input             ena,
  input      [3:0]  wea,
  input      [9:0]  addra,
  input      [31:0] dina,
  output reg [31:0] douta
);
  reg [31:0] mem [0:1023];
  integer    i;

  initial begin
    $display("DMEM: loading dmem.hex");
    $readmemh("dmem.hex", mem);
  end

  always @(posedge clka) begin
    if (ena) begin
      if (|wea) begin
        if (wea[0]) mem[addra][ 7: 0] <= dina[ 7: 0];
        if (wea[1]) mem[addra][15: 8] <= dina[15: 8];
        if (wea[2]) mem[addra][23:16] <= dina[23:16];
        if (wea[3]) mem[addra][31:24] <= dina[31:24];
      end
      douta <= mem[addra];
    end
  end
endmodule
