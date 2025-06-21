`timescale 1ns / 1ps

//-----------------------------------------------------------------------------  
// Top-Level Integration Module for RISC-V 5-Stage Pipeline  
//-----------------------------------------------------------------------------  
module riscv5stage_top(
    input  wire        clk,
    input  wire        rst,
    output wire        debug_led
);
    // Pipeline interconnect signals
    wire        stall, flush;
    wire        branch_taken;
    wire [31:0] branch_target;
    wire [1:0]  forwardA, forwardB;

    // IF Stage
    wire [31:0] IF_PC, IF_Instr, IF_PC_plus4;
    IF_stage u_IF_stage(
        .clk(clk), .rst(rst), .stall(stall), .flush(flush),
        .branch_target(branch_target), .branch_taken(branch_taken),
        .PC(IF_PC), .Instr(IF_Instr), .PC_plus4(IF_PC_plus4)
    );
    wire [31:0] ID_PC, ID_Instr;
    IF_ID u_IF_ID(
        .clk(clk), .rst(rst), .stall(stall), .flush(flush),
        .PC_in(IF_PC), .Instr_in(IF_Instr),
        .PC_out(ID_PC), .Instr_out(ID_Instr)
    );

    // ID Stage
    wire [31:0] ID_RegData1, ID_RegData2, ID_Imm;
    wire [4:0]  ID_Rs1, ID_Rs2, ID_Rd;
    wire [6:0]  ID_Opcode, ID_Funct7;
    wire [2:0]  ID_Funct3;
    wire        ID_MemRead, ID_MemWrite, ID_RegWrite, ID_MemtoReg;
    wire [3:0]  ID_ALUOp;
    wire        WB_en;
    wire [4:0]  WB_addr;
    wire [31:0] WB_data;
    ID_stage u_ID_stage(
        .clk(clk), .rst(rst),
        .Instr_in(ID_Instr), .PC_in(ID_PC),
        .WB_en(WB_en), .WB_addr(WB_addr), .WB_data(WB_data),
        .RegData1(ID_RegData1), .RegData2(ID_RegData2),
        .Imm(ID_Imm), .Rs1(ID_Rs1), .Rs2(ID_Rs2), .Rd(ID_Rd),
        .Opcode(ID_Opcode), .Funct3(ID_Funct3), .Funct7(ID_Funct7),
        .MemRead(ID_MemRead), .MemWrite(ID_MemWrite),
        .RegWrite(ID_RegWrite), .MemtoReg(ID_MemtoReg), .ALUOp(ID_ALUOp)
    );

    // Hazard Unit
    hazard_unit u_hazard(
        .ID_EX_MemRead(ID_MemRead),
        .ID_EX_Rd(ID_Rd),
        .IF_ID_Rs1(ID_Rs1),
        .IF_ID_Rs2(ID_Rs2),
        .stall(stall),
        .flush(flush)
    );

    // ID/EX Register
    wire [31:0] EX_PC, EX_RegData1, EX_RegData2, EX_Imm;
    wire [4:0]  EX_Rs1, EX_Rs2, EX_Rd;
    wire [6:0]  EX_Opcode, EX_Funct7;
    wire [2:0]  EX_Funct3;
    wire        EX_MemRead, EX_MemWrite, EX_RegWrite, EX_MemtoReg;
    wire [3:0]  EX_ALUOp;
    ID_EX u_ID_EX(
        .clk(clk), .rst(rst), .stall(stall), .flush(flush),
        .PC_in(ID_PC),
        .RegData1_in(ID_RegData1), .RegData2_in(ID_RegData2), .Imm_in(ID_Imm),
        .Rs1_in(ID_Rs1), .Rs2_in(ID_Rs2), .Rd_in(ID_Rd),
        .Opcode_in(ID_Opcode), .Funct3_in(ID_Funct3), .Funct7_in(ID_Funct7),
        .MemRead_in(ID_MemRead), .MemWrite_in(ID_MemWrite),
        .RegWrite_in(ID_RegWrite), .MemtoReg_in(ID_MemtoReg), .ALUOp_in(ID_ALUOp),
        .PC_out(EX_PC), .RegData1_out(EX_RegData1), .RegData2_out(EX_RegData2),
        .Imm_out(EX_Imm), .Rs1_out(EX_Rs1), .Rs2_out(EX_Rs2), .Rd_out(EX_Rd),
        .Opcode_out(EX_Opcode), .Funct3_out(EX_Funct3), .Funct7_out(EX_Funct7),
        .MemRead_out(EX_MemRead), .MemWrite_out(EX_MemWrite),
        .RegWrite_out(EX_RegWrite), .MemtoReg_out(EX_MemtoReg), .ALUOp_out(EX_ALUOp)
    );

forwarding_unit u_forward(
    .EX_MEM_RegWrite(MEM_RegWrite),  // EX/MEM.RegWrite_out
    .EX_MEM_Rd      (MEM_Rd),        // EX/MEM.Rd_out
    .MEM_WB_RegWrite(WB_en),
    .MEM_WB_Rd      (WB_addr),
    .ID_EX_Rs1      (EX_Rs1),
    .ID_EX_Rs2      (EX_Rs2),
    .forwardA       (forwardA),
    .forwardB       (forwardB)
);

    // EX Stage & EX/MEM Register
    wire        EX_Zero;
    wire [31:0] EX_ALUResult, EX_BranchTarget;
    wire [31:0] EX_ForwardedB;
EX_stage u_EX_stage(
    .clk          (clk),
    .MemRead      (EX_MemRead),
    .MemWrite     (EX_MemWrite),
    .RegWrite     (EX_RegWrite),
    .MemtoReg     (EX_MemtoReg),
    .ALUOp        (EX_ALUOp),
    .Opcode       (EX_Opcode),
    .Funct3       (EX_Funct3),
    .Funct7       (EX_Funct7),
    .PC_in        (EX_PC),
    .RegData1     (EX_RegData1),
    .RegData2     (EX_RegData2),
    .Imm          (EX_Imm),
    .Rd_in        (EX_Rd),
    .forwardA     (forwardA),
    .forwardB     (forwardB),
    .EX_MEM_ALU   (MEM_ALUResult),
    .MEM_WB_Data  (WB_data),
    .Zero         (EX_Zero),
    .ALUResult    (EX_ALUResult),
    .BranchTarget (EX_BranchTarget),
    .ForwardedB   (EX_ForwardedB)
);

    // EX/MEM Pipeline Register
    wire [31:0] MEM_ALUResult, MEM_StoreData;
    wire [4:0]  MEM_Rd;
    wire        MEM_MemRead, MEM_MemWrite, MEM_RegWrite, MEM_MemtoReg;
    EX_MEM u_EX_MEM(
        .clk(clk), .rst(rst),
        .ALURes_in(EX_ALUResult), .StoreData_in(EX_ForwardedB),
        .Rd_in(EX_Rd), .MemRead_in(EX_MemRead), .MemWrite_in(EX_MemWrite),
        .RegWrite_in(EX_RegWrite), .MemtoReg_in(EX_MemtoReg),
        .ALURes_out(MEM_ALUResult), .StoreData_out(MEM_StoreData),
        .Rd_out(MEM_Rd), .MemRead_out(MEM_MemRead), .MemWrite_out(MEM_MemWrite),
        .RegWrite_out(MEM_RegWrite), .MemtoReg_out(MEM_MemtoReg)
    );

    // MEM Stage & MEM/WB Register
    wire [31:0] MEM_ReadData, MEM_ALU_out;
    wire [4:0]  MEM_Rd_WB;
    wire        MEM_RegWrite_WB, MEM_MemtoReg_WB;
    MEM_stage u_MEM_stage(
        .clk(clk), .ALU_in(MEM_ALUResult), .store_data(MEM_StoreData),
        .MemRead(MEM_MemRead), .MemWrite(MEM_MemWrite),
        .RegWrite(MEM_RegWrite), .MemtoReg(MEM_MemtoReg),
        .rd_in(MEM_Rd), .read_data(MEM_ReadData), .ALU_out(MEM_ALU_out),
        .rd_out(MEM_Rd_WB), .RegWrite_out(MEM_RegWrite_WB), .MemtoReg_out(MEM_MemtoReg_WB)
    );

    // MEM/WB Pipeline Register
    wire [31:0] WB_MemData, WB_ALURes;
    wire        WB_MemtoReg;
    MEM_WB u_MEM_WB(
        .clk(clk), .rst(rst),
        .MemData_in(MEM_ReadData), .ALURes_in(MEM_ALU_out),
        .Rd_in(MEM_Rd_WB), .RegWrite_in(MEM_RegWrite_WB), .MemtoReg_in(MEM_MemtoReg_WB),
        .MemData_out(WB_MemData), .ALURes_out(WB_ALURes),
        .Rd_out(WB_addr), .RegWrite_out(WB_en), .MemtoReg_out(WB_MemtoReg)
    );

    // Writeback
    assign WB_data = WB_MemtoReg ? WB_MemData : WB_ALURes;

    // Branch Logic & Debug LED
    assign branch_taken  = EX_Zero && (EX_Opcode == 7'b1100011);
    assign branch_target = EX_BranchTarget;
    assign debug_led     = EX_Zero;

endmodule
