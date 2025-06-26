`timescale 1ns/1ps
module tb_riscv5stage;

  reg         clk, rst;
  reg  [3:0]  switches;
  wire [3:0]  leds;
  wire        debug_led;

  // Instantiate with the new I/O ports:
  riscv5stage_top dut (
    .clk       (clk),
    .rst       (rst),
    .switches  (switches),
    .leds      (leds),
    .debug_led (debug_led)
  );

  // clock & reset
  initial begin clk = 0; forever #5 clk = ~clk; end
  initial begin rst = 1; #20 rst = 0; end

  // apply a pattern on switches so we hit the I/O code
  initial begin
    switches = 4'b0000;   #50;
    switches = 4'b0001;   // turn on SW0 → expect LED0
    #100 switches = 4'b0010;  // turn on SW1 → expect LED1
    #100 switches = 4'b0000;
  end

  // load your new imem
  initial begin
    $readmemh("imem.hex", dut.u_IF_stage.imem);
    $readmemh("dmem.hex", dut.u_MEM_stage.dmem);
  end

  // monitor
  initial begin
    $display("time PC     Instr  SW LED dbg");
    $monitor("%4dns: %h %h  %b  %b   %b",
             $time,
             dut.u_IF_stage.PC,
             dut.u_IF_stage.Instr,
             switches,
             leds,
             debug_led);
  end

  initial #500 $finish;
endmodule
