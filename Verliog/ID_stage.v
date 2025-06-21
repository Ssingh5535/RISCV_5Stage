`timescale 1ns / 1ps

//-------------------------
// ID Stage (Instruction Decode) with debug prints
//-------------------------
module ID_stage(
    input         clk,
    input         rst,
    input  [31:0] Instr_in,
    input  [31:0] PC_in,
    // Write-back inputs
    input         WB_en,
    input  [4:0]  WB_addr,
    input  [31:0] WB_data,
    // Decode outputs
    output [31:0] RegData1,
    output [31:0] RegData2,
    output [31:0] Imm,
    output [4:0]  Rs1, Rs2, Rd,
    output [6:0]  Opcode,
    output [2:0]  Funct3,
    output [6:0]  Funct7,
    output        MemRead,
    output        MemWrite,
    output        RegWrite,
    output        MemtoReg,
    output [3:0]  ALUOp
);

  // Instruction fields
  assign Opcode = Instr_in[6:0];
  assign Rd     = Instr_in[11:7];
  assign Funct3 = Instr_in[14:12];
  assign Rs1    = Instr_in[19:15];
  assign Rs2    = Instr_in[24:20];
  assign Funct7 = Instr_in[31:25];

  // Immediate generator
  reg [31:0] imm;
  always @(*) begin
    case (Opcode)
      7'b0000011, 7'b0010011: // I-type (loads, immediate ALU)
        imm = {{20{Instr_in[31]}}, Instr_in[31:20]};
      7'b0100011: // S-type (stores)
        imm = {{20{Instr_in[31]}}, Instr_in[31:25], Instr_in[11:7]};
      7'b1100011: // B-type (branches)
        imm = {{19{Instr_in[31]}}, Instr_in[31], Instr_in[7],
               Instr_in[30:25], Instr_in[11:8], 1'b0};
      default:
        imm = 32'b0;
    endcase
  end
  assign Imm = imm;

  // ------------------------------------------------
  // Register file with write-back bypass
  // ------------------------------------------------
  reg [31:0] regs [0:31];
  integer    i;

  // Read ports with forwarding from WB stage
  assign RegData1 = (WB_en && (WB_addr != 0) && (WB_addr == Rs1))
                    ? WB_data
                    : regs[Rs1];

  assign RegData2 = (WB_en && (WB_addr != 0) && (WB_addr == Rs2))
                    ? WB_data
                    : regs[Rs2];

  // Write-back and reset
  always @(posedge clk) begin
    if (rst) begin
      for (i = 0; i < 32; i = i + 1)
        regs[i] <= 32'b0;
    end else if (WB_en && (WB_addr != 0)) begin
      regs[WB_addr] <= WB_data;
    end
  end

  // ------------------------------------------------
  // Control unit
  // ------------------------------------------------
  reg        rMemRead, rMemWrite, rRegWrite, rMemtoReg;
  reg [3:0]  rALUOp;
  always @(*) begin
    // Defaults
    rMemRead  = 1'b0;
    rMemWrite = 1'b0;
    rRegWrite = 1'b0;
    rMemtoReg = 1'b0;
    rALUOp    = 4'b0000;
    case (Opcode)
      7'b0110011: begin // R-type
        rRegWrite = 1'b1;
        rALUOp    = 4'b0010; // ADD/SUB
      end
      7'b0000011: begin // Load (I-type)
        rMemRead  = 1'b1;
        rRegWrite = 1'b1;
        rMemtoReg = 1'b1;
        rALUOp    = 4'b0000; // ADD for address
      end
      7'b0100011: begin // Store (S-type)
        rMemWrite = 1'b1;
        rALUOp    = 4'b0000; // ADD for address
      end
      7'b1100011: begin // Branch (B-type)
        rALUOp    = 4'b0110; // SUB for comparison
      end
      7'b0010011: begin // I-ALU
        rRegWrite = 1'b1;
        rALUOp    = 4'b0000; // ADDI
      end
      default: begin
        // NOP or unsupported: no ops
      end
    endcase
  end

  assign {MemRead, MemWrite, RegWrite, MemtoReg, ALUOp} =
         {rMemRead, rMemWrite, rRegWrite, rMemtoReg, rALUOp};


  // ------------------------------------------------
  // Debug print when decoding an R-type ADD
  // ------------------------------------------------
  // We use a combinational always block so it prints whenever Instr_in indicates ADD.
  // Note: ensure simulation time (#) is appropriate; this prints every time the instruction
  //       in ID is the ADD, showing the read operands and WB signals.
  always @(*) begin
    if (Opcode == 7'b0110011 && Funct3 == 3'b000 && Funct7 == 7'b0000000) begin
      $display("[%0t] ID_STAGE ADD DECODE: Rs1=%0d Rs2=%0d RegData1=0x%h RegData2=0x%h WB_en=%b WB_addr=%0d WB_data=0x%h",
               $time, Rs1, Rs2, RegData1, RegData2,
               WB_en, WB_addr, WB_data);
    end
  end

endmodule
