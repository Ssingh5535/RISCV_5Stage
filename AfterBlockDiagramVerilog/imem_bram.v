//`timescale 1ns / 1ps
////------------------------------------------------------------------------------
//// imem_bram.v: simple synchronous ROM, 32-bit words, depth = 2^ADDR_BITS
////------------------------------------------------------------------------------
//module imem_bram #(
//  parameter ADDR_BITS = 10
//)(
//  input               clka,
//  input               ena,
//  input  [3:0]        wea,      // tie to 0
//  input  [ADDR_BITS-1:0] addra,
//  input  [31:0]       dina,     // ignored
//  output reg [31:0]   douta
//);

//  // 2^ADDR_BITS words
//  reg [31:0] mem [0:(1<<ADDR_BITS)-1];

//  initial begin
//    $readmemh("imem.hex", mem);
//  end

//  always @(posedge clka) begin
//    if (ena) begin
//      douta <= mem[addra];
//    end
//  end

//endmodule


`timescale 1ns / 1ps
module imem_bram (
  input             clka,
  input             ena,
  input      [0:0]  wea,
  input      [9:0]  addra,
  input      [31:0] dina,
  output reg [31:0] douta
);
  // depth = 2^10 = 1024
  reg [31:0] mem [0:1023];
  integer    i;

  // initialize from file
  initial begin
    $display("IMEM: loading imem.hex");
    $readmemh("imem.hex", mem);
  end

  always @(posedge clka) begin
    if (ena) begin
      if (wea)
        mem[addra] <= dina;
      douta <= mem[addra];
    end
  end
endmodule
