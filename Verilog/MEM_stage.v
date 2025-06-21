//-------------------------
// MEM Stage Module with debug prints
//-------------------------
module MEM_stage(
    input         clk,
    input  [31:0] ALU_in,
    input  [31:0] store_data,
    input         MemRead,
    input         MemWrite,
    input         RegWrite,
    input         MemtoReg,
    input  [4:0]  rd_in,
    output reg [31:0] read_data,
    output      [31:0] ALU_out,
    output      [4:0]  rd_out,
    output      RegWrite_out,
    output      MemtoReg_out
);
  reg [31:0] dmem [0:1023];
  initial $readmemh("dmem.hex", dmem);

  always @(posedge clk) begin
    if (MemWrite) begin
      dmem[ALU_in[11:2]] <= store_data;
      $display("[%0t] STORE: addr=0x%h data=0x%h", $time, ALU_in, store_data);
    end
    if (MemRead) begin
      read_data <= dmem[ALU_in[11:2]];
      $display("[%0t] LOAD : addr=0x%h data=0x%h", $time, ALU_in, dmem[ALU_in[11:2]]);
    end
  end

  assign ALU_out      = ALU_in;
  assign rd_out       = rd_in;
  assign RegWrite_out = RegWrite;
  assign MemtoReg_out = MemtoReg;
endmodule
