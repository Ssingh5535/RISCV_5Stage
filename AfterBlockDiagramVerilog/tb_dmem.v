`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2025 05:50:57 PM
// Design Name: 
// Module Name: tb_dmem
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

module tb_dmem;
  localparam ADDR_BITS = 10;
  reg         clk = 0;
  reg         ena;
  reg  [3:0]  wea;
  reg  [ADDR_BITS-1:0] addr;
  reg  [31:0] dina;
  wire [31:0] dout;

  dmem_bram #(.ADDR_BITS(ADDR_BITS)) dut (
    .clka(clk), .ena(ena), .wea(wea),
    .addra(addr), .dina(dina),
    .douta(dout)
  );

  always #5 clk = ~clk;

  initial begin
    // optional: load initial contents if you like
    #1;

    // Write a pattern at address 5
    ena = 1; addr = 5; dina = 32'habcd1234; wea = 4'b1111; #10;
    wea = 4'b0000;                      // stop writing
    #10;
    if (dout !== 32'habcd1234) $display("ERR: readback mismatch");
    else                 $display("dmem_bram test passed.");
    $finish;
  end
endmodule
