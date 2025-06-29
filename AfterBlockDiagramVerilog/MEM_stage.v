`timescale 1ns / 1ps

//-----------------------------------------------------------------------------
// MEM Stage Module with memory-mapped I/O and debug prints
//-----------------------------------------------------------------------------
module MEM_stage(
    input         clk,
    input         rst,
    input  [31:0] ALU_in,        // byte address from EX stage
    input  [31:0] store_data,    // data to write on store
    input         MemRead,       // asserted for loads
    input         MemWrite,      // asserted for stores
    input         RegWrite,      // pass-through
    input         MemtoReg,      // pass-through
    input  [4:0]  rd_in,         // pass-through
    // I/O ports
    input  [31:0] io_switches,   // lower [3:0] are the 4 physical switches
    output reg [3:0] io_leds,    // drives the 4 physical LEDs
    // standard pipeline outputs
    output reg [31:0] read_data,
    output      [31:0] ALU_out,
    output      [4:0]  rd_out,
    output      RegWrite_out,
    output      MemtoReg_out
);

  // memory-mapped I/O addresses (byte addresses)
  localparam [31:0] SWITCH_ADDR = 32'h00000010;
  localparam [31:0] LED_ADDR    = 32'h00000014;

  // depth = 1024 words => 4K bytes
  reg [31:0] dmem [0:1023];
  integer    i;

  // on simulation load an initial file (optional)
  initial begin
    $readmemh("dmem.hex", dmem);
  end

  // synchronous reset + load/store/I/O
  always @(posedge clk) begin
    if (rst) begin
      // clear I/O
      io_leds   <= 4'b0;
      read_data <= 32'b0;
      // clear memory if you want:
      for (i = 0; i < 1024; i = i + 1)
        dmem[i] <= 32'b0;
    end else begin
      // STORE
      if (MemWrite) begin
        if (ALU_in == LED_ADDR) begin
          // memory-mapped LED write
          io_leds <= store_data[3:0];
          $display("[%0t] IO WRITE LED: addr=0x%h data=0x%h",
                    $time, ALU_in, store_data);
        end else begin
          // ordinary data RAM write
          dmem[ ALU_in[11:2] ] <= store_data;
          $display("[%0t] STORE: addr=0x%h data=0x%h",
                    $time, ALU_in, store_data);
        end
      end

      // LOAD
      if (MemRead) begin
        if (ALU_in == SWITCH_ADDR) begin
          // memory-mapped switch read
          read_data <= {28'b0, io_switches[3:0]};
          $display("[%0t] IO READ SWITCH: addr=0x%h data=0x%h",
                    $time, ALU_in, read_data);
        end else if (ALU_in == LED_ADDR) begin
          // allow reads of LED state if desired
          read_data <= {28'b0, io_leds};
          $display("[%0t] IO READ LED: addr=0x%h data=0x%h",
                    $time, ALU_in, read_data);
        end else begin
          // ordinary data RAM read
          read_data <= dmem[ ALU_in[11:2] ];
          $display("[%0t] LOAD : addr=0x%h data=0x%h",
                    $time, ALU_in, dmem[ ALU_in[11:2] ]);
        end
      end
    end
  end

  // pass-throughs into MEM/WB
  assign ALU_out      = ALU_in;
  assign rd_out       = rd_in;
  assign RegWrite_out = RegWrite;
  assign MemtoReg_out = MemtoReg;

endmodule
