`timescale 1ns / 1ps

//-------------------------
// EX Stage Module with enhanced debug prints
//-------------------------
module EX_stage(
    input         clk,          // clock for sequential debug prints
    input         MemRead,
    input         MemWrite,
    input         RegWrite,
    input         MemtoReg,
    input  [3:0]  ALUOp,
    input  [6:0]  Opcode,
    input  [2:0]  Funct3,
    input  [6:0]  Funct7,
    input  [31:0] PC_in,
    input  [31:0] RegData1,
    input  [31:0] RegData2,
    input  [31:0] Imm,
    input  [4:0]  Rd_in,
    input  [1:0]  forwardA,
    input  [1:0]  forwardB,
    input  [31:0] EX_MEM_ALU,
    input  [31:0] MEM_WB_Data,
    output reg        Zero,
    output reg [31:0] ALUResult,
    output reg [31:0] BranchTarget,
    output     [31:0] ForwardedB  // forwarded B operand for stores
);

  // Forwarding muxes for ALU operands
  // operandA: forwarded from EX/MEM or MEM/WB or from RegData1
  wire [31:0] operandA_raw = RegData1;
  wire [31:0] operandA = (forwardA == 2'b01) ? EX_MEM_ALU :
                         (forwardA == 2'b10) ? MEM_WB_Data  :
                                               operandA_raw;

  // operandB_raw: forwarded from EX/MEM or MEM/WB or from RegData2
  wire [31:0] operandB_raw = (forwardB == 2'b01) ? EX_MEM_ALU :
                              (forwardB == 2'b10) ? MEM_WB_Data  :
                                                   RegData2;

  // Expose forwarded raw B for memory stores
  assign ForwardedB = operandB_raw;

  // Select immediate for loads, stores, I-type; else use operandB_raw for R-type, etc.
  wire [31:0] operandB = (Opcode == 7'b0000011  // load
                         || Opcode == 7'b0100011  // store
                         || Opcode == 7'b0010011) // I-arith
                         ? Imm : operandB_raw;

  // ALU Operation and branch target
  always @(*) begin
    case (ALUOp)
      4'b0010: ALUResult = operandA + operandB;  // ADD or R-type
      4'b0110: ALUResult = operandA - operandB;  // SUB or branch compare
      default: ALUResult = operandA + operandB;  // Default ADD
    endcase
    Zero = (ALUResult == 0);
    BranchTarget = PC_in + Imm;

    // Debug print for R-type ADD in EX stage, showing forwarding paths
    if (Opcode == 7'b0110011 && Funct3 == 3'b000 && Funct7 == 7'b0000000) begin
      $display("[%0t] EX_STAGE ADD: forwardA=%b forwardB=%b operandA_raw=0x%h operandB_raw=0x%h operandA=0x%h operandB=0x%h ALUResult=0x%h (Rd=%0d)",
               $time,
               forwardA, forwardB,
               operandA_raw, operandB_raw,
               operandA, operandB,
               ALUResult,
               Rd_in);
    end
  end

  // Debug print for store data forwarding (when this instruction is SW in EX stage)
  always @(posedge clk) begin
    if (MemWrite) begin
      // ALU address is ALUResult (operandA + Imm) - can print ALUResult if available, 
      // but here operandA+Imm is same as ALUResult for address calculation.
      $display("[%0t] EX_STAGE STORE DATA: forwardA=%b forwardB=%b operandA_raw=0x%h Imm=0x%h ALU_addr=0x%h operandB_raw=0x%h ForwardedB=0x%h",
               $time,
               forwardA, forwardB,
               operandA_raw, Imm, 
               (operandA + Imm),
               operandB_raw,
               ForwardedB);
    end
  end

endmodule