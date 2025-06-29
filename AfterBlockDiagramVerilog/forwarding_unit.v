// forwarding_unit.v
module forwarding_unit(
    input  wire        EX_MEM_RegWrite,
    input  wire [4:0]  EX_MEM_Rd,
    input  wire        MEM_WB_RegWrite,
    input  wire [4:0]  MEM_WB_Rd,
    input  wire [4:0]  ID_EX_Rs1,
    input  wire [4:0]  ID_EX_Rs2,
    output reg  [1:0]  forwardA,
    output reg  [1:0]  forwardB
);
  always @(*) begin
    // Default: no forwarding
    forwardA = 2'b00;
    forwardB = 2'b00;
    // EX hazard (forward from EX/MEM stage)
    if (EX_MEM_RegWrite && (EX_MEM_Rd != 5'b0)) begin
      if (EX_MEM_Rd == ID_EX_Rs1)
        forwardA = 2'b01;
      if (EX_MEM_Rd == ID_EX_Rs2)
        forwardB = 2'b01;
    end
    // MEM hazard (forward from MEM/WB stage)
    // Note: only if EX hazard did not already forward
    if (MEM_WB_RegWrite && (MEM_WB_Rd != 5'b0)) begin
      if ((MEM_WB_Rd == ID_EX_Rs1) && (forwardA == 2'b00))
        forwardA = 2'b10;
      if ((MEM_WB_Rd == ID_EX_Rs2) && (forwardB == 2'b00))
        forwardB = 2'b10;
    end
  end
endmodule