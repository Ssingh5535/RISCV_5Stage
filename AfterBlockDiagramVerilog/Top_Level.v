//`timescale 1ns/1ps

////-----------------------------------------------------------------------------  
//// Top-Level Integration Module for RISC-V 5-Stage Pipeline with GPIO and BRAMs   
////-----------------------------------------------------------------------------  
//module riscv5stage_top #(
//  parameter IMEM_ADDR_BITS = 10,
//  parameter DMEM_ADDR_BITS = 10,
//  // address at which we declare the program "done"
//  parameter DONE_PC       = 32'h0000_4100,
//  // board clock freq (Hz) for the ring generator
//  parameter CLK_FREQ      = 125_000_000,
//  // how many ticks between ring steps: here CLK_FREQ/5 → 5 Hz rotation
//  parameter STEP_PERIOD   = CLK_FREQ/4
//)(
//  input  wire        clk,
//  input  wire        rst,
//  input  wire [3:0]  switches,   // physical switches
//  output wire [3:0]  leds,       // physical LEDs
//  output wire        debug_led   // pipeline-zero indicator
//);

//  // ------------------------------------------------------------------------
//  // 1) Pipeline control & forwarding signals
//  // ------------------------------------------------------------------------
//  wire        stall, flush;
//  wire [1:0]  forwardA, forwardB;

//  // ------------------------------------------------------------------------
//  // 2) Fetch stage outputs
//  // ------------------------------------------------------------------------
//  wire [31:0] IF_PC, IF_Instr, IF_PC_plus4;
//  wire        branch_taken;
//  wire [31:0] branch_target;

//  // ------------------------------------------------------------------------
//  // 3) Instruction BRAM
//  // ------------------------------------------------------------------------
//  wire [IMEM_ADDR_BITS-1:0] imem_addr = IF_PC[IMEM_ADDR_BITS+1:2];
//  wire [31:0]               imem_q;
//  imem_bram imem_inst (
//    .clka   (clk), .ena(1'b1), .wea(4'b0),
//    .addra  (imem_addr), .dina(32'b0), .douta(imem_q)
//  );

//  // ------------------------------------------------------------------------
//  // 4) IF stage
//  // ------------------------------------------------------------------------
//  IF_stage u_IF (
//    .clk(clk), .rst(rst), .stall(stall), .flush(flush),
//    .branch_taken(branch_taken), .branch_target(branch_target),
//    .imem_q(imem_q), .PC(IF_PC), .Instr(IF_Instr), .PC_plus4(IF_PC_plus4)
//  );

//  // ------------------------------------------------------------------------
//  // 5) IF/ID register
//  // ------------------------------------------------------------------------
//  wire [31:0] ID_PC, ID_Instr;
//  IF_ID u_IF_ID (
//    .clk(clk), .rst(rst), .stall(stall), .flush(flush),
//    .PC_in(IF_PC), .Instr_in(IF_Instr),
//    .PC_out(ID_PC), .Instr_out(ID_Instr)
//  );

//  // ------------------------------------------------------------------------
//  // 6) ID stage
//  // ------------------------------------------------------------------------
//  wire [31:0] ID_RegData1, ID_RegData2, ID_Imm;
//  wire [4:0]  ID_Rs1, ID_Rs2, ID_Rd;
//  wire [6:0]  ID_Opcode, ID_Funct7;
//  wire [2:0]  ID_Funct3;
//  wire        ID_MemRead, ID_MemWrite, ID_RegWrite, ID_MemtoReg;
//  wire [3:0]  ID_ALUOp;
//  wire        WB_en;
//  wire [4:0]  WB_addr;
//  wire [31:0] WB_data;

//  ID_stage u_ID (
//    .clk(clk), .rst(rst),
//    .Instr_in(ID_Instr), .PC_in(ID_PC),
//    .WB_en(WB_en), .WB_addr(WB_addr), .WB_data(WB_data),
//    .RegData1(ID_RegData1), .RegData2(ID_RegData2),
//    .Imm(ID_Imm), .Rs1(ID_Rs1), .Rs2(ID_Rs2), .Rd(ID_Rd),
//    .Opcode(ID_Opcode), .Funct3(ID_Funct3), .Funct7(ID_Funct7),
//    .MemRead(ID_MemRead), .MemWrite(ID_MemWrite),
//    .RegWrite(ID_RegWrite), .MemtoReg(ID_MemtoReg), .ALUOp(ID_ALUOp)
//  );

//  // ------------------------------------------------------------------------
//  // 7) Hazard detection (load-use)
//  // ------------------------------------------------------------------------
//  wire        EX_MemtoReg;
//  wire [4:0]  EX_Rd;
//  hazard_unit u_hazard (
//    .ID_EX_MemtoReg(EX_MemtoReg),
//    .ID_EX_Rd     (EX_Rd),
//    .IF_ID_Rs1    (ID_Rs1),
//    .IF_ID_Rs2    (ID_Rs2),
//    .stall        (stall),
//    .flush        (flush)
//  );

//  // ------------------------------------------------------------------------
//  // 8) ID/EX register
//  // ------------------------------------------------------------------------
//  wire [31:0] EX_PC, EX_RegData1, EX_RegData2, EX_Imm;
//  wire [4:0]  EX_Rs1, EX_Rs2;
//  wire        EX_MemRead, EX_RegWrite;
//  wire [3:0]  EX_ALUOp;
//  ID_EX u_ID_EX (
//    .clk(clk), .rst(rst), .stall(stall), .flush(flush),
//    .PC_in        (ID_PC),
//    .RegData1_in  (ID_RegData1), .RegData2_in(ID_RegData2), .Imm_in(ID_Imm),
//    .Rs1_in       (ID_Rs1),      .Rs2_in(ID_Rs2),      .Rd_in(ID_Rd),
//    .Opcode_in    (ID_Opcode),   .Funct3_in(ID_Funct3),.Funct7_in(ID_Funct7),
//    .MemRead_in   (ID_MemRead),  .MemWrite_in(ID_MemWrite),
//    .RegWrite_in  (ID_RegWrite), .MemtoReg_in(ID_MemtoReg), .ALUOp_in(ID_ALUOp),
//    .PC_out       (EX_PC),
//    .RegData1_out (EX_RegData1), .RegData2_out(EX_RegData2), .Imm_out(EX_Imm),
//    .Rs1_out      (EX_Rs1),      .Rs2_out(EX_Rs2),      .Rd_out(EX_Rd),
//    .MemRead_out  (EX_MemRead),  .MemtoReg_out(EX_MemtoReg), .ALUOp_out(EX_ALUOp),
//    .RegWrite_out ()  // unused here
//  );

//  // ------------------------------------------------------------------------
//  // 9) Forwarding unit
//  // ------------------------------------------------------------------------
//  wire        MEM_RegWrite;
//  wire [4:0]  MEM_Rd;
//  forwarding_unit u_forward (
//    .EX_MEM_RegWrite(MEM_RegWrite), .EX_MEM_Rd(MEM_Rd),
//    .MEM_WB_RegWrite(WB_en),        .MEM_WB_Rd(WB_addr),
//    .ID_EX_Rs1(EX_Rs1),             .ID_EX_Rs2(EX_Rs2),
//    .forwardA(forwardA),            .forwardB(forwardB)
//  );

//  // ------------------------------------------------------------------------
//  // 10) EX stage
//  // ------------------------------------------------------------------------
//  wire        EX_Zero;
//  wire [31:0] EX_ALUResult, EX_BranchTarget, EX_ForwardedB;
//  EX_stage u_EX (
//    .clk(clk),
//    .MemRead(EX_MemRead), .MemWrite(ID_MemWrite),
//    .RegWrite(ID_RegWrite), .MemtoReg(ID_MemtoReg), .ALUOp(EX_ALUOp),
//    .Opcode(ID_Opcode), .Funct3(ID_Funct3), .Funct7(ID_Funct7),
//    .PC_in(EX_PC),
//    .RegData1(EX_RegData1), .RegData2(EX_RegData2),
//    .Imm(EX_Imm), .Rd_in(EX_Rd),
//    .forwardA(forwardA), .forwardB(forwardB),
//    .EX_MEM_ALU(MEM_ALUResult), .MEM_WB_Data(WB_data),
//    .Zero(EX_Zero), .ALUResult(EX_ALUResult),
//    .BranchTarget(EX_BranchTarget), .ForwardedB(EX_ForwardedB)
//  );

//  // ------------------------------------------------------------------------
//  // 11) EX/MEM register
//  // ------------------------------------------------------------------------
//  wire [31:0] MEM_ALUResult, MEM_StoreData;
//  EX_MEM u_EX_MEM (
//    .clk(clk), .rst(rst),
//    .ALURes_in(EX_ALUResult), .StoreData_in(EX_ForwardedB),
//    .Rd_in(EX_Rd),
//    .MemRead_in(EX_MemRead), .MemWrite_in(ID_MemWrite),
//    .RegWrite_in(ID_RegWrite), .MemtoReg_in(ID_MemtoReg),
//    .ALURes_out(MEM_ALUResult), .StoreData_out(MEM_StoreData),
//    .Rd_out(MEM_Rd), .RegWrite_out(MEM_RegWrite)
//  );

//  // ------------------------------------------------------------------------
//  // 12) Data BRAM + MMIO
//  // ------------------------------------------------------------------------
//  localparam SWITCH_ADDR = 32'h10, LED_ADDR = 32'h14;
//  wire [DMEM_ADDR_BITS-1:0] dmem_addr = MEM_ALUResult[DMEM_ADDR_BITS+1:2];
//  wire [31:0]               dmem_q;
//  wire [3:0]                dmem_wea = ID_MemWrite ? 4'b1111 : 4'b0000;
//  dmem_bram data_bram_inst (
//    .clka(clk), .ena(ID_MemRead|ID_MemWrite), .wea(dmem_wea),
//    .addra(dmem_addr), .dina(MEM_StoreData), .douta(dmem_q)
//  );

//  reg [3:0]  io_leds_reg;
//  reg [31:0] mem_rd_data;
//  always @(posedge clk) begin
//    if (rst) begin
//      io_leds_reg <= 4'b1111;
//      mem_rd_data <= 0;
//    end else begin
//      if (!program_done && ID_MemWrite && MEM_ALUResult == LED_ADDR)
//        io_leds_reg <= MEM_StoreData[3:0];

//      if (ID_MemRead) begin
//        if      (MEM_ALUResult == SWITCH_ADDR) mem_rd_data <= {28'b0, switches};
//        else if (MEM_ALUResult == LED_ADDR   ) mem_rd_data <= {28'b0, io_leds_reg};
//        else                                   mem_rd_data <= dmem_q;
//      end
//    end
//  end

//  // ------------------------------------------------------------------------
//  // 13) MEM/WB register & single-driver write-back
//  // ------------------------------------------------------------------------
//  wire [31:0] WB_MemDataReg, WB_ALUResReg;
//  MEM_WB u_MEM_WB (
//    .clk         (clk),    .rst(rst),
//    .MemData_in  (mem_rd_data),
//    .ALURes_in   (MEM_ALUResult),
//    .Rd_in       (MEM_Rd),
//    .RegWrite_in (MEM_RegWrite),
//    .MemtoReg_in (EX_MemtoReg),
//    .MemData_out (WB_MemDataReg),
//    .ALURes_out  (WB_ALUResReg),
//    .Rd_out      (WB_addr),
//    .RegWrite_out(WB_en)
//  );
//  // only this assign drives WB_data
//  wire [31:0] WB_data = EX_MemtoReg ? WB_MemDataReg : WB_ALUResReg;

//  // ------------------------------------------------------------------------
//  // 14) Branch logic & debug LED
//  // ------------------------------------------------------------------------
//  assign branch_taken = EX_Zero && (ID_Opcode == 7'b1100011);
//  assign debug_led    = EX_Zero;

//  // ------------------------------------------------------------------------
//  // 15) Success-ring display (5 Hz on 125 MHz)
//  // ------------------------------------------------------------------------
//  reg        program_done;
//  reg [3:0]  led_ring;

//  // prescaler for ring step
//  reg [26:0] slow_cnt;
//  reg        tick_step;
//  always @(posedge clk) begin
//    if (rst) begin
//      slow_cnt  <= 0;
//      tick_step <= 0;
//    end else if (slow_cnt == STEP_PERIOD-1) begin
//      slow_cnt  <= 0;
//      tick_step <= 1;
//    end else begin
//      slow_cnt  <= slow_cnt + 1;
//      tick_step <= 0;
//    end
//  end

//  always @(posedge clk) begin
//    if (rst) begin
//      program_done <= 1'b0;
//      led_ring     <= 4'b0001;
//    end else begin
//      // latch done once
//      if (!program_done && IF_PC == DONE_PC)
//        program_done <= 1'b1;
//      // rotate only at our slow tick
//      if (program_done && tick_step)
//        led_ring <= {led_ring[0], led_ring[3:1]};
//    end
//  end

//  // select between MMIO-driven LEDs or our ring
// wire [3:0] raw_leds = program_done ? led_ring : io_leds_reg;
//// invert for the Z2's active-low LEDs:
//assign leds = ~raw_leds;
//endmodule


//`timescale 1ns/1ps

////-----------------------------------------------------------------------------  
//// Top-Level Integration Module for RISC-V 5-Stage Pipeline with GPIO and BRAMs   
////-----------------------------------------------------------------------------  
//module riscv5stage_top #(
//  parameter IMEM_ADDR_BITS = 10,
//  parameter DMEM_ADDR_BITS = 10,
//  parameter DONE_PC       = 32'h0000_4100,
//  parameter CLK_FREQ      = 125_000_000,
//  parameter STEP_PERIOD   = 4
//)(
//  input  wire        clk,
//  input  wire        rst,
//  input  wire [3:0]  switches,

//  // Primary outputs
//  output wire [3:0]  leds,
//  output wire        debug_led,

//  // Exposed internals for TB
//  output wire        stall,
//  output wire        flush,
//  output wire        EX_MemRead,
//  output wire        EX_MemWrite,
//  output wire [31:0] MEM_ALUResult,
//  output wire [31:0] MEM_StoreData,
//  output wire [31:0] MEM_ReadData,
//  output wire [4:0]  EX_Rd,
//  output wire [4:0]  ID_Rs1,
//  output wire [4:0]  ID_Rs2,
//  output wire        program_done,
//  output wire [3:0]  led_ring,
//  output wire        tick_step
//);
//  // ------------------------------------------------------------------------
//  // 1) Pipeline control & forwarding signals
//  // ------------------------------------------------------------------------
//  wire        stall, flush;
//  wire [1:0]  forwardA, forwardB;

//  // ------------------------------------------------------------------------
//  // 2) Fetch stage outputs
//  // ------------------------------------------------------------------------
//  wire [31:0] IF_PC, IF_Instr, IF_PC_plus4;
//  wire        branch_taken;
//  wire [31:0] branch_target;

//  // ------------------------------------------------------------------------
//  // 3) Instruction BRAM
//  // ------------------------------------------------------------------------
//  wire [IMEM_ADDR_BITS-1:0] imem_addr = IF_PC[IMEM_ADDR_BITS+1:2];
//  wire [31:0]               imem_q;
//  imem_bram imem_inst (
//    .clka   (clk), .ena(1'b1), .wea(4'b0),
//    .addra  (imem_addr), .dina(32'b0), .douta(imem_q)
//  );

//  // ------------------------------------------------------------------------
//  // 4) IF stage
//  // ------------------------------------------------------------------------
//  IF_stage u_IF (
//    .clk(clk), .rst(rst), .stall(stall), .flush(flush),
//    .branch_taken(branch_taken), .branch_target(branch_target),
//    .imem_q(imem_q), .PC(IF_PC), .Instr(IF_Instr), .PC_plus4(IF_PC_plus4)
//  );

//  // ------------------------------------------------------------------------
//  // 5) IF/ID register
//  // ------------------------------------------------------------------------
//  wire [31:0] ID_PC, ID_Instr;
//  IF_ID u_IF_ID (
//    .clk(clk), .rst(rst), .stall(stall), .flush(flush),
//    .PC_in(IF_PC), .Instr_in(IF_Instr),
//    .PC_out(ID_PC), .Instr_out(ID_Instr)
//  );

//  // ------------------------------------------------------------------------
//  // 6) ID stage
//  // ------------------------------------------------------------------------
//  wire [31:0] ID_RegData1, ID_RegData2, ID_Imm;
//  wire [4:0]  ID_Rs1, ID_Rs2, ID_Rd;
//  wire [6:0]  ID_Opcode, ID_Funct7;
//  wire [2:0]  ID_Funct3;
//  wire        ID_MemRead, ID_MemWrite, ID_RegWrite, ID_MemtoReg;
//  wire [3:0]  ID_ALUOp;
//  wire        WB_en;
//  wire [4:0]  WB_addr;
//  wire [31:0] WB_data;

//  ID_stage u_ID (
//    .clk(clk), .rst(rst),
//    .Instr_in(ID_Instr), .PC_in(ID_PC),
//    .WB_en(WB_en), .WB_addr(WB_addr), .WB_data(WB_data),
//    .RegData1(ID_RegData1), .RegData2(ID_RegData2),
//    .Imm(ID_Imm), .Rs1(ID_Rs1), .Rs2(ID_Rs2), .Rd(ID_Rd),
//    .Opcode(ID_Opcode), .Funct3(ID_Funct3), .Funct7(ID_Funct7),
//    .MemRead(ID_MemRead), .MemWrite(ID_MemWrite),
//    .RegWrite(ID_RegWrite), .MemtoReg(ID_MemtoReg), .ALUOp(ID_ALUOp)
//  );

//  // ------------------------------------------------------------------------
//  // 7) Hazard detection (load-use)
//  // ------------------------------------------------------------------------
//  wire        EX_MemtoReg;
//  wire [4:0]  EX_Rd;
//  hazard_unit u_hazard (
//    .ID_EX_MemtoReg(EX_MemtoReg),
//    .ID_EX_Rd     (EX_Rd),
//    .IF_ID_Rs1    (ID_Rs1),
//    .IF_ID_Rs2    (ID_Rs2),
//    .stall        (stall),
//    .flush        (flush)
//  );

//  // ------------------------------------------------------------------------
//  // 8) ID/EX register
//  // ------------------------------------------------------------------------
//  wire [31:0] EX_PC, EX_RegData1, EX_RegData2, EX_Imm;
//  wire [4:0]  EX_Rs1, EX_Rs2;
//  wire        EX_MemRead, EX_RegWrite;
//  wire [3:0]  EX_ALUOp;
//  ID_EX u_ID_EX (
//    .clk(clk), .rst(rst), .stall(stall), .flush(flush),
//    .PC_in        (ID_PC),
//    .RegData1_in  (ID_RegData1), .RegData2_in(ID_RegData2), .Imm_in(ID_Imm),
//    .Rs1_in       (ID_Rs1),      .Rs2_in(ID_Rs2),      .Rd_in(ID_Rd),
//    .Opcode_in    (ID_Opcode),   .Funct3_in(ID_Funct3),.Funct7_in(ID_Funct7),
//    .MemRead_in   (ID_MemRead),  .MemWrite_in(ID_MemWrite),
//    .RegWrite_in  (ID_RegWrite), .MemtoReg_in(ID_MemtoReg), .ALUOp_in(ID_ALUOp),
//    .PC_out       (EX_PC),
//    .RegData1_out (EX_RegData1), .RegData2_out(EX_RegData2), .Imm_out(EX_Imm),
//    .Rs1_out      (EX_Rs1),      .Rs2_out(EX_Rs2),      .Rd_out(EX_Rd),
//    .MemRead_out  (EX_MemRead),  .MemtoReg_out(EX_MemtoReg), .ALUOp_out(EX_ALUOp)
//  );

//  // ------------------------------------------------------------------------
//  // 9) Forwarding unit
//  // ------------------------------------------------------------------------
//  wire        MEM_RegWrite;
//  wire [4:0]  MEM_Rd;
//  forwarding_unit u_forward (
//    .EX_MEM_RegWrite(MEM_RegWrite), .EX_MEM_Rd(MEM_Rd),
//    .MEM_WB_RegWrite(WB_en),        .MEM_WB_Rd(WB_addr),
//    .ID_EX_Rs1(EX_Rs1),             .ID_EX_Rs2(EX_Rs2),
//    .forwardA(forwardA),            .forwardB(forwardB)
//  );

//  // ------------------------------------------------------------------------
//  // 10) EX stage
//  // ------------------------------------------------------------------------
//  wire        EX_Zero;
//  wire [31:0] EX_ALUResult, EX_BranchTarget, EX_ForwardedB;
//  EX_stage u_EX (
//    .clk(clk),
//    .MemRead(EX_MemRead), .MemWrite(ID_MemWrite),
//    .RegWrite(ID_RegWrite), .MemtoReg(ID_MemtoReg), .ALUOp(EX_ALUOp),
//    .Opcode(ID_Opcode), .Funct3(ID_Funct3), .Funct7(ID_Funct7),
//    .PC_in(EX_PC),
//    .RegData1(EX_RegData1), .RegData2(EX_RegData2),
//    .Imm(EX_Imm), .Rd_in(EX_Rd),
//    .forwardA(forwardA), .forwardB(forwardB),
//    .EX_MEM_ALU(MEM_ALUResult), .MEM_WB_Data(WB_data),
//    .Zero(EX_Zero), .ALUResult(EX_ALUResult),
//    .BranchTarget(EX_BranchTarget), .ForwardedB(EX_ForwardedB)
//  );

//  // ------------------------------------------------------------------------
//  // 11) EX/MEM register
//  // ------------------------------------------------------------------------
//  EX_MEM u_EX_MEM (
//    .clk(clk), .rst(rst),
//    .ALURes_in(EX_ALUResult), .StoreData_in(EX_ForwardedB),
//    .Rd_in(EX_Rd),
//    .MemRead_in(EX_MemRead), .MemWrite_in(ID_MemWrite),
//    .RegWrite_in(ID_RegWrite), .MemtoReg_in(ID_MemtoReg),
//    .ALURes_out(MEM_ALUResult), .StoreData_out(MEM_StoreData),
//    .Rd_out(MEM_Rd), .RegWrite_out(MEM_RegWrite)
//  );

//  // ------------------------------------------------------------------------
//  // 12) Data BRAM + MMIO
//  // ------------------------------------------------------------------------
//  localparam SWITCH_ADDR = 32'h10, LED_ADDR = 32'h14;
//  wire [DMEM_ADDR_BITS-1:0] dmem_addr = MEM_ALUResult[DMEM_ADDR_BITS+1:2];
//  wire [31:0]               dmem_q;
//  wire [3:0]                dmem_wea = ID_MemWrite ? 4'b1111 : 4'b0000;
//  dmem_bram data_bram_inst (
//    .clka(clk), .ena(ID_MemRead|ID_MemWrite), .wea(dmem_wea),
//    .addra(dmem_addr), .dina(MEM_StoreData), .douta(dmem_q)
//  );

//  // ------------------------------------------------------------------------
//  // 13) MMIO + regfile readback
//  // ------------------------------------------------------------------------
//  reg [3:0]  io_leds_reg;
//  reg [31:0] mem_rd_data;
//  always @(posedge clk) begin
//    if (rst) begin
//      io_leds_reg <= 0;
//      mem_rd_data <= 0;
//    end else begin
//      if (!program_done && ID_MemWrite && MEM_ALUResult == LED_ADDR)
//        io_leds_reg <= MEM_StoreData[3:0];

//      if (ID_MemRead) begin
//        if      (MEM_ALUResult == SWITCH_ADDR) mem_rd_data <= {28'b0, switches};
//        else if (MEM_ALUResult == LED_ADDR   ) mem_rd_data <= {28'b0, io_leds_reg};
//        else                                   mem_rd_data <= dmem_q;
//      end
//    end
//  end

//  // ------------------------------------------------------------------------
//  // 14) MEM/WB register & single-driver write-back
//  // ------------------------------------------------------------------------
//  wire [31:0] WB_MemDataReg, WB_ALUResReg;
//  MEM_WB u_MEM_WB (
//    .clk         (clk),    .rst(rst),
//    .MemData_in  (mem_rd_data),
//    .ALURes_in   (MEM_ALUResult),
//    .Rd_in       (MEM_Rd),
//    .RegWrite_in (MEM_RegWrite),
//    .MemtoReg_in (EX_MemtoReg),
//    .MemData_out (WB_MemDataReg),
//    .ALURes_out  (WB_ALUResReg),
//    .Rd_out      (WB_addr),
//    .RegWrite_out(WB_en)
//  );
//  wire [31:0] WB_data = EX_MemtoReg ? WB_MemDataReg : WB_ALUResReg;

//  // ------------------------------------------------------------------------
//  // 15) Branch logic & debug LED
//  // ------------------------------------------------------------------------
//  assign branch_taken = EX_Zero && (ID_Opcode == 7'b1100011);
//  assign debug_led    = EX_Zero;

//  // ------------------------------------------------------------------------
//  // 16) Success-ring display (4 Hz on 125 MHz)
//  // ------------------------------------------------------------------------
//  reg        program_done;
//  reg  [3:0] led_ring;
//  reg [26:0] slow_cnt;
//  reg        tick_step;

//  always @(posedge clk) begin
//    if (rst) begin
//      slow_cnt  <= 0;
//      tick_step <= 0;
//    end else if (slow_cnt == STEP_PERIOD-1) begin
//      slow_cnt  <= 0;
//      tick_step <= 1;
//    end else begin
//      slow_cnt  <= slow_cnt + 1;
//      tick_step <= 0;
//    end
//  end

//  always @(posedge clk) begin
//    if (rst) begin
//      program_done <= 1'b0;
//      led_ring     <= 4'b0001;
//    end else begin
//      if (!program_done && IF_PC == DONE_PC)
//        program_done <= 1'b1;
//      if (program_done && tick_step)
//        led_ring <= {led_ring[0], led_ring[3:1]};
//    end
//  end

//  // expose the slow-tick to TB
//  wire ring_tick = tick_step;

//  // select between MMIO-driven LEDs or our ring
// wire [3:0] raw_leds = program_done ? led_ring : io_leds_reg;
//// invert for the Z2's active-low LEDs:
//assign leds = ~raw_leds;
//endmodule





`timescale 1ns/1ps

module riscv5stage_top #(
  parameter IMEM_ADDR_BITS = 10,
  parameter DMEM_ADDR_BITS = 10,
  parameter DONE_PC        = 32'h0000_4100,
  parameter CLK_FREQ       = 50_000_000,
  parameter STEP_PERIOD    = CLK_FREQ/4
)(
  // global
  input  wire                   clk,
  input  wire                   rst,

  // memory-mapped I/O
  input  wire [3:0]             switches,
  output wire [3:0]             leds,
  output wire                   debug_led,

  // IMEM face-plate (to Block RAM Generator)
  output wire                   imem_ena,
  output wire [3:0]             imem_wea,
  output wire [IMEM_ADDR_BITS-1:0] imem_addra,
  output wire [31:0]            imem_dina,
  input  wire [31:0]            imem_douta,

  // DMEM face-plate (to Block RAM Generator)
  output wire                   dmem_ena,
  output wire [3:0]             dmem_wea,
  output wire [DMEM_ADDR_BITS-1:0] dmem_addra,
  output wire [31:0]            dmem_dina,
  input  wire [31:0]            dmem_douta
);

  // --------------------------------------------------------------------------
  // 1) Pipeline control & forwarding signals
  // --------------------------------------------------------------------------
  wire        stall, flush;
  wire [1:0]  forwardA, forwardB;

  // --------------------------------------------------------------------------
  // 2) Fetch stage outputs
  // --------------------------------------------------------------------------
  wire [31:0] IF_PC, IF_Instr, IF_PC_plus4;
  wire        branch_taken;
  wire [31:0] branch_target;

  // --------------------------------------------------------------------------
  // 3) IMEM hookup
  // --------------------------------------------------------------------------
  assign imem_ena   = 1'b1;
  assign imem_wea   = 4'b0000;                                 // no write
  assign imem_addra = IF_PC[IMEM_ADDR_BITS+1:2];
  assign imem_dina  = 32'b0;
  wire [31:0] imem_q = imem_douta;

  // --------------------------------------------------------------------------
  // 4) IF stage
  // --------------------------------------------------------------------------
  IF_stage u_IF (
    .clk         (clk),
    .rst         (rst),
    .stall       (stall),
    .flush       (flush),
    .branch_taken(branch_taken),
    .branch_target(branch_target),
    .imem_q      (imem_q),
    .PC          (IF_PC),
    .Instr       (IF_Instr),
    .PC_plus4    (IF_PC_plus4)
  );

  // --------------------------------------------------------------------------
  // 5) IF/ID pipeline register
  // --------------------------------------------------------------------------
  wire [31:0] ID_PC, ID_Instr;
  IF_ID u_IF_ID (
    .clk    (clk),
    .rst    (rst),
    .stall  (stall),
    .flush  (flush),
    .PC_in  (IF_PC),
    .Instr_in(ID_Instr),
    .PC_out (ID_PC),
    .Instr_out(ID_Instr)
  );

  // --------------------------------------------------------------------------
  // 6) ID stage
  // --------------------------------------------------------------------------
  wire [31:0] ID_RegData1, ID_RegData2, ID_Imm;
  wire [4:0]  ID_Rs1, ID_Rs2, ID_Rd;
  wire [6:0]  ID_Opcode, ID_Funct7;
  wire [2:0]  ID_Funct3;
  wire        ID_MemRead, ID_MemWrite, ID_RegWrite, ID_MemtoReg;
  wire [3:0]  ID_ALUOp;
  wire        WB_en;
  wire [4:0]  WB_addr;
  wire [31:0] WB_data;

  ID_stage u_ID (
    .clk        (clk),
    .rst        (rst),
    .Instr_in   (ID_Instr),
    .PC_in      (ID_PC),
    .WB_en      (WB_en),
    .WB_addr    (WB_addr),
    .WB_data    (WB_data),
    .RegData1   (ID_RegData1),
    .RegData2   (ID_RegData2),
    .Imm        (ID_Imm),
    .Rs1        (ID_Rs1),
    .Rs2        (ID_Rs2),
    .Rd         (ID_Rd),
    .Opcode     (ID_Opcode),
    .Funct3     (ID_Funct3),
    .Funct7     (ID_Funct7),
    .MemRead    (ID_MemRead),
    .MemWrite   (ID_MemWrite),
    .RegWrite   (ID_RegWrite),
    .MemtoReg   (ID_MemtoReg),
    .ALUOp      (ID_ALUOp)
  );

  // --------------------------------------------------------------------------
  // 7) Hazard detection & forwarding units
  // --------------------------------------------------------------------------
  wire        EX_MemtoReg;
  wire [4:0]  EX_Rd;
  hazard_unit u_hazard (
    .ID_EX_MemtoReg(EX_MemtoReg),
    .ID_EX_Rd      (EX_Rd),
    .IF_ID_Rs1     (ID_Rs1),
    .IF_ID_Rs2     (ID_Rs2),
    .stall         (stall),
    .flush         (flush)
  );

  wire        MEM_RegWrite;
  wire [4:0]  MEM_Rd;
  forwarding_unit u_forward (
    .EX_MEM_RegWrite(MEM_RegWrite),
    .EX_MEM_Rd      (MEM_Rd),
    .MEM_WB_RegWrite(WB_en),
    .MEM_WB_Rd      (WB_addr),
    .ID_EX_Rs1      (EX_Rs1),
    .ID_EX_Rs2      (EX_Rs2),
    .forwardA       (forwardA),
    .forwardB       (forwardB)
  );

  // --------------------------------------------------------------------------
  // 8) EX stage + EX/MEM pipeline register
  // --------------------------------------------------------------------------
  wire        EX_Zero;
  wire [31:0] EX_ALUResult, EX_BranchTarget, EX_ForwardedB;
  EX_stage u_EX (
    .clk         (clk),
    .MemRead     (EX_MemRead),
    .MemWrite    (ID_MemWrite),
    .RegWrite    (ID_RegWrite),
    .MemtoReg    (ID_MemtoReg),
    .ALUOp       (ID_ALUOp),
    .Opcode      (ID_Opcode),
    .Funct3      (ID_Funct3),
    .Funct7      (ID_Funct7),
    .PC_in       (EX_PC),
    .RegData1    (EX_RegData1),
    .RegData2    (EX_RegData2),
    .Imm         (EX_Imm),
    .Rd_in       (EX_Rd),
    .forwardA    (forwardA),
    .forwardB    (forwardB),
    .EX_MEM_ALU  (MEM_ALUResult),   // feed EX/MEM output back
    .MEM_WB_Data (WB_data),
    .Zero        (EX_Zero),
    .ALUResult   (EX_ALUResult),
    .BranchTarget(branch_target),
    .ForwardedB  (EX_ForwardedB)
  );

  wire [31:0] MEM_ALUResult, MEM_StoreData;
  EX_MEM u_EX_MEM (
    .clk          (clk),
    .rst          (rst),
    .ALURes_in    (EX_ALUResult),
    .StoreData_in (EX_ForwardedB),
    .Rd_in        (EX_Rd),
    .MemRead_in   (EX_MemRead),
    .MemWrite_in  (ID_MemWrite),
    .RegWrite_in  (ID_RegWrite),
    .MemtoReg_in  (ID_MemtoReg),
    .ALURes_out   (MEM_ALUResult),
    .StoreData_out(MEM_StoreData),
    .Rd_out       (MEM_Rd),
    .RegWrite_out (MEM_RegWrite),
    .MemRead_out  (/*unused*/),     // tie off if not needed
    .MemWrite_out (/*unused*/),
    .MemtoReg_out (/*unused*/)
  );

  // --------------------------------------------------------------------------
  // 9) Data BRAM + MMIO
  // --------------------------------------------------------------------------
  localparam SWITCH_ADDR = 32'h10,
             LED_ADDR    = 32'h14;

  // expose exactly these four ports to the wrapper:
  assign dmem_ena   = ID_MemRead | ID_MemWrite;
  assign dmem_wea   = ID_MemWrite ? 4'b1111 : 4'b0000;
  assign dmem_addra = MEM_ALUResult[DMEM_ADDR_BITS+1:2];  // <-- your slice now works
  assign dmem_dina  = MEM_StoreData;
  wire [31:0] dmem_q = dmem_douta;

  // memory-mapped LEDs
  reg [3:0]  io_leds_reg;
  reg [31:0] mem_rd_data;
  always @(posedge clk) begin
    if (rst) begin
      io_leds_reg <= 4'b0000;
      mem_rd_data <= 32'b0;
    end else begin
      if (ID_MemWrite && MEM_ALUResult == LED_ADDR)
        io_leds_reg <= MEM_StoreData[3:0];

      if (ID_MemRead) begin
        if      (MEM_ALUResult == SWITCH_ADDR) mem_rd_data <= {28'b0, switches};
        else if (MEM_ALUResult == LED_ADDR   ) mem_rd_data <= {28'b0, io_leds_reg};
        else                                   mem_rd_data <= dmem_q;
      end
    end
  end

  // --------------------------------------------------------------------------
  // 10) MEM/WB + write-back
  // --------------------------------------------------------------------------
  wire [31:0] WB_MemDataReg, WB_ALUResReg;
  MEM_WB u_MEM_WB (
    .clk         (clk),
    .rst         (rst),
    .MemData_in  (mem_rd_data),
    .ALURes_in   (MEM_ALUResult),
    .Rd_in       (MEM_Rd),
    .RegWrite_in (MEM_RegWrite),
    .MemtoReg_in (EX_MemtoReg),
    .MemData_out (WB_MemDataReg),
    .ALURes_out  (WB_ALUResReg),
    .Rd_out      (WB_addr),
    .RegWrite_out(WB_en),
    .MemtoReg_out(/*unused*/)
  );
  assign WB_data = EX_MemtoReg ? WB_MemDataReg : WB_ALUResReg;

  // --------------------------------------------------------------------------
  // 11) Branch logic & debug LED
  // --------------------------------------------------------------------------
  assign branch_taken = EX_Zero && (ID_Opcode == 7'b1100011);
  assign debug_led    = EX_Zero;

  // --------------------------------------------------------------------------
  // 12) Success-ring generator
  // --------------------------------------------------------------------------
  reg [3:0]  led_ring;
  reg        program_done;
  reg [26:0] slow_cnt;
  reg        tick_step;

  always @(posedge clk) begin
    if (rst) begin
      slow_cnt  <= 27'b0;
      tick_step <= 1'b0;
    end else if (slow_cnt == STEP_PERIOD-1) begin
      slow_cnt  <= 27'b0;
      tick_step <= 1'b1;
    end else begin
      slow_cnt  <= slow_cnt + 1;
      tick_step <= 1'b0;
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      program_done <= 1'b0;
      led_ring     <= 4'b0001;
    end else begin
      if (!program_done && IF_PC == DONE_PC)
        program_done <= 1'b1;
      if (program_done && tick_step)
        led_ring <= {led_ring[0], led_ring[3:1]};
    end
  end

  // --------------------------------------------------------------------------
  // 13) Final LED mux
  // --------------------------------------------------------------------------
  assign leds = program_done ? led_ring : io_leds_reg;

endmodule
