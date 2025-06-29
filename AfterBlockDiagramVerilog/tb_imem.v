`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2025 05:50:57 PM
// Design Name: 
// Module Name: tb_imem
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

module tb_imem;
  // Parameters must match your module
  localparam ADDR_BITS = 10;
  reg         clk = 0;
  reg         ena = 1;
  reg  [3:0]  wea = 4'b0000;
  reg  [ADDR_BITS-1:0] addr;
  wire [31:0] dout;

  // Instantiate
  imem_bram #(.ADDR_BITS(ADDR_BITS)) dut (
    .clka(clk), .ena(ena), .wea(wea),
    .addra(addr),
    .dina(32'b0),       // ignored
    .douta(dout)
  );

  // Clock
  always #5 clk = ~clk;

  initial begin
    // Let the ROM load its file
    #1;

    // Check first few addresses against your imem.hex
    addr = 0;  #10; if (dout !== 32'hfe010113) $display("ERR at addr 0");
    addr = 1;  #10; if (dout !== 32'h00112e23) $display("ERR at addr 1");
    addr = 2;  #10; if (dout !== 32'h00812c23) $display("ERR at addr 2");
    // …and so on…
    $display("imem_bram test done.");
    $finish;
  end
endmodule
