//`timescale 1ns / 1ps

////-----------------------------------------------------------------------------  
//// Testbench for riscv5stage_top (memory-port version) with ring-blink check
////-----------------------------------------------------------------------------

//module tb_riscv5stage;

//  // Clock & reset
//  reg        clk = 0;
//  reg        rst;

//  // I/O ports
//  reg  [3:0] switches = 0;
//  wire [3:0] leds;
//  wire       debug_led;

//  // expose internals from DUT
//  wire       stall, flush;
//  wire       EX_MemRead, EX_MemWrite;
//  wire [31:0] MEM_ALUResult, MEM_StoreData, MEM_ReadData;
//  wire [4:0] EX_Rd, ID_Rs1, ID_Rs2;

//  // the two new signals
//  wire       program_done;
//  wire [3:0] led_ring;

//  // Instantiate the DUT
//  riscv5stage_top #(
//    .IMEM_ADDR_BITS(10),
//    .DMEM_ADDR_BITS(10)
//  ) dut (
//    .clk        (clk),
//    .rst        (rst),
//    .switches   (switches),
//    .leds       (leds),
//    .debug_led  (debug_led)
//    // everything else is internal
//  );

//  // tie out internal nets (make sure your riscv5stage_top declares these regs)
//  assign stall         = dut.stall;
//  assign flush         = dut.flush;
//  assign EX_MemRead    = dut.EX_MemRead;
//  assign MEM_ALUResult = dut.MEM_ALUResult;
//  assign MEM_StoreData = dut.MEM_StoreData;
//  assign MEM_ReadData  = dut.mem_rd_data;
//  assign EX_Rd          = dut.EX_Rd;
//  assign ID_Rs1         = dut.ID_Rs1;
//  assign ID_Rs2         = dut.ID_Rs2;

//  assign program_done = dut.program_done;
//  assign led_ring     = dut.led_ring;

//  // 100 MHz clock
//  always #5 clk = ~clk;

//  // Reset pulse
//  initial begin
//    rst = 1;
//    #20;
//    rst = 0;
//  end

//  // Switch stimulus
//  initial begin
//    #100  switches = 4'b0001;
//    #200  switches = 4'b0010;
//    #200  switches = 4'b0100;
//    #200  switches = 4'b1000;
//    #200  switches = 4'b0000;
//  end

//  //-----------------------------------------------------------------------------  
//  // LED-MMIO write watch  
//  //-----------------------------------------------------------------------------

//  initial begin
//    $display("\n--- LED/MMIO & ring-blink watch ---");
//    $monitor("Time %4dns: EX_MemWrite=%b  Addr=%h  StoreData=%h  io_leds_reg=%b  leds=%b  program_done=%b  led_ring=%b",
//      $time,
//      EX_MemWrite,
//      MEM_ALUResult,
//      MEM_StoreData,
//      dut.io_leds_reg,
//      leds,
//      program_done,
//      led_ring
//    );
//  end

//  //-----------------------------------------------------------------------------  
//  // Load-Use hazard trace  
//  //-----------------------------------------------------------------------------

//  initial begin
//    #0;
//    $display("\n--- Load-Use Hazard Trace ---");
//    $monitor("Time %4dns: stall=%b flush=%b | EX_MemRead=%b EX_Rd=%h | ID_Rs1=%h ID_Rs2=%h",
//      $time,
//      stall, flush,
//      EX_MemRead, EX_Rd,
//      ID_Rs1, ID_Rs2
//    );
//  end

//  // Stop after enough time to see the ring spin
//  initial begin
//    #50000;
//    $display("** Simulation complete **");
//    $finish;
//  end

//endmodule

`timescale 1ns / 1ps

//-----------------------------------------------------------------------------  
// Testbench for riscv5stage_top (memory-port version) with ring-blink check
//-----------------------------------------------------------------------------  

module tb_riscv5stage;

  // Clock & reset
  reg        clk = 0;
  reg        rst;

  // I/O ports
  reg  [3:0] switches = 0;
  wire [3:0] leds;
  wire       debug_led;

  // expose internals from DUT
  wire       stall, flush;
  wire       EX_MemRead, EX_MemWrite;
  wire [31:0] MEM_ALUResult, MEM_StoreData, MEM_ReadData;
  wire [4:0] EX_Rd, ID_Rs1, ID_Rs2;

  // the two new signals
  wire       program_done;
  wire [3:0] led_ring;
  wire       ring_tick;

  // Instantiate the DUT
  riscv5stage_top #(
    .IMEM_ADDR_BITS(10),
    .DMEM_ADDR_BITS(10)
  ) dut (
    .clk        (clk),
    .rst        (rst),
    .switches   (switches),
    .leds       (leds),
    .debug_led  (debug_led)
    // everything else is internal
  );

  // tie out internal nets (make sure your riscv5stage_top declares these regs)
  assign stall         = dut.stall;
  assign flush         = dut.flush;
  assign EX_MemRead    = dut.EX_MemRead;
  assign EX_MemWrite   = dut.EX_MemWrite;
  assign MEM_ALUResult = dut.MEM_ALUResult;
  assign MEM_StoreData = dut.MEM_StoreData;
  assign MEM_ReadData  = dut.mem_rd_data;
  assign EX_Rd         = dut.EX_Rd;
  assign ID_Rs1        = dut.ID_Rs1;
  assign ID_Rs2        = dut.ID_Rs2;

  assign program_done  = dut.program_done;
  assign led_ring      = dut.led_ring;
  assign ring_tick     = dut.tick_step;  // expose your slow-tick signal

  // 100 MHz clock
  always #5 clk = ~clk;

  // Reset pulse
  initial begin
    rst = 1;
    #20;
    rst = 0;
  end

  // Switch stimulus
  initial begin
    #100  switches = 4'b0001;
    #200  switches = 4'b0010;
    #200  switches = 4'b0100;
    #200  switches = 4'b1000;
    #200  switches = 4'b0000;
  end

  //-----------------------------------------------------------------------------  
  // LED-MMIO write watch  
  //-----------------------------------------------------------------------------  

  initial begin
    $display("\n--- LED/MMIO & ring-blink watch ---");
    $monitor("Time %4dns: EX_MemWrite=%b  Addr=%h  StoreData=%h  io_leds_reg=%b  leds=%b  program_done=%b  led_ring=%b",
      $time,
      EX_MemWrite,
      MEM_ALUResult,
      MEM_StoreData,
      dut.io_leds_reg,
      leds,
      program_done,
      led_ring
    );
  end

  //-----------------------------------------------------------------------------  
  // Load-Use hazard trace  
  //-----------------------------------------------------------------------------  

  initial begin
    #0;
    $display("\n--- Load-Use Hazard Trace ---");
    $monitor("Time %4dns: stall=%b flush=%b | EX_MemRead=%b EX_Rd=%h | ID_Rs1=%h ID_Rs2=%h",
      $time,
      stall, flush,
      EX_MemRead, EX_Rd,
      ID_Rs1, ID_Rs2
    );
  end

  //-----------------------------------------------------------------------------  
  // Ring-blink diagnostic
  //-----------------------------------------------------------------------------  

  initial begin
    $display("\n--- RING-BLINK DIAGNOSTIC ---");
    $monitor("Time %0t: IF_PC=%h  program_done=%b  ring_tick=%b  io_leds_reg=%b  led_ring=%b  leds=%b",
      $time,
      dut.IF_PC,
      program_done,
      ring_tick,
      dut.io_leds_reg,
      led_ring,
      leds
    );
  end
// print only on the slow-tick that rotates the LEDs
always @(posedge clk) begin
  if (dut.tick_step) begin
    $display(">> %0dns: ring step!  led_ring=%b  leds=%b",
             $time, dut.led_ring, leds);
  end
end
  // Stop after enough time to see the ring spin
  initial begin
    #50000;
    $display("** Simulation complete **");
    $finish;
  end

endmodule
