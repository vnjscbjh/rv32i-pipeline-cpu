`timescale 1ns / 1ps
module riscv(clk, rst,DR_out,out_ins);
    input clk, rst;
    output DR_out,out_ins;
    // **************************
    // 信号定义
    // **************************
    // 控制信号
    wire RFWrite,DMCtrl,PCWrite,IRWrite,InsMemRW,ExtSel,zero,ALUSrcA,read,bubble;
    wire [1:0] ALUSrcB,ALUSrcB_EX;
    wire [1:0] NPCOp,WDSel, RegSel;
    wire [3:0] ALUOp;
    // 指令相关字段
    wire [6:0] opcode;
    wire [2:0] Funct3;
    wire [6:0] Funct7;
    wire [31:0] PC, NPC, PCA4,ALU_result_r;
    wire [31:0] in_ins, out_ins, RD, DR_out;
    wire [4:0] rs1, rs2, rd;
    wire [4:0] WR;
    wire [31:0] WD;
    wire [31:0] RD1, RD1_r, RD2, RD2_r,real_B;
    wire [31:0] A, B, ALU_result;
    // 立即数/偏移量
    wire [11:0] Imm12;
    wire [31:0] Imm32;
    wire [20:1] Offset20;
    wire [11:0] Offset;
    // --- 逻辑压杆：定义各级流水线影子信号 ---
    // --- 冒险检测信号 ---
    wire Stall; // 对应 Load-Use 冒险
    wire Flush; // 对应 分支/跳转清空
    wire [1:0] ForwardA,ForwardB;


    // 指令字段提取
    assign opcode   = out_ins[6:0];
    assign Funct3   = out_ins[14:12];
    assign Funct7   = out_ins[31:25];
    assign rs1      = out_ins[19:15];
    assign rs2      = out_ins[24:20];
    assign rd       = out_ins[11:7];
    assign Imm12    = out_ins[31:20];
    // 偏移量逻辑
    assign Offset20 = {out_ins[31],out_ins[19:12],out_ins[20],out_ins[30:21]};
    assign Offset   = (opcode == `OP_B_TYPE) ? {out_ins[31],out_ins[7],out_ins[30:25],out_ins[11:8]} :
                      (opcode == `OP_STORE)  ? {out_ins[31:25],out_ins[11:7]} : Imm12;

    // E单元 » ControlUnit
    ControlUnit U_ControlUnit(
        .clk(clk), .rst(rst), .zero(zero), .opcode(opcode), .Funct7(Funct7), .Funct3(Funct3),
        .rs1(rs1), .rs2(rs2),
        .WR(WR),.PCWrite(PCWrite), .IRWrite(IRWrite), .Stall(Stall), .Flush(Flush),
        .ALUop(ALUOp), .NPCop(NPCOp), .DMCtrl(DMCtrl), .ExtSel(ExtSel),
        .ALUSrcA(ALUSrcA),.ALUSrcB(ALUSrcB), .RegSel(RegSel), .WDSel(WDSel),
        .RFWrite(RFWrite), .InsMemRW(InsMemRW),.ALUSrcB_EX(ALUSrcB_EX),
        .ForwardA(ForwardA), .ForwardB(ForwardB),.bubble(bubble)
    );
    // PC
    PC U_PC (
        .clk(clk), .rst(rst), .PCWrite(PCWrite), .NPC(NPC), .PC(PC)
    );

    // NPC
    NPC U_NPC (
        .PC(PC), .NPCOp(NPCOp), .Offset12(Offset), .Offset20(Offset20), .zero(zero), .rs(RD1[31:2]), .ALU_result(ALU_result),
        .clk(clk),.flush(Flush),.PCA4(PCA4), .NPC(NPC),.stall(Stall)
    );

    // IM
    IM U_IM (
        .addr(PC[11:2]), .Ins(in_ins), .InsMemRW(InsMemRW),.clk(clk),.flush(Flush),.IRWrite(IRWrite)
    );

    // IR
    IR U_IR (
        .clk(clk), .IRWrite(IRWrite) ,.in_ins(in_ins), .out_ins(out_ins),.rst(rst)
    );

    // RF
    RF U_RF (
        .RR1(rs1), .RR2(rs2), .WR(WR), .WD(WD), .clk(clk),
        .RFWrite(RFWrite), .RD1(RD1), .RD2(RD2)
    );

    // MUX_3to1
    MUX_3to1 U_MUX_3to1 (
        .X(rd), .Y(5'd0), .Z(5'd31),
        .control(RegSel), .out(WR)
    );
    // MUX_3to1_LMD
    MUX_3to1_LMD U_MUX_3to1_LMD (
        .X(ALU_result_r), .Y(DR_out), .Z(PCA4),
        .control(WDSel), .out(WD),.clk(clk),.rst(rst)
    );

     Flopr  U_A (
        .clk(clk), .rst(rst), .en(1'b1), .flush(Flush), .in_data(RD1), .out_data(RD1_r)
    );

    Flopr  U_B (
        .clk(clk), .rst(rst), .en(1'b1), .flush(Flush), .in_data(RD2), .out_data(RD2_r)
    );

    // EXT
    EXT U_EXT (
        .imm_in(Imm12), .ExtSel(ExtSel), .imm_out(Imm32),.out_ins(out_ins)
    );

    // MUX 2to1 A
    MUX_2to1_A U_MUX_2to1_A (
        .X(RD1_r), .Y(32'h0), .control(ALUSrcA),.out(A)
    );
    
    // MUX_3to1_B
    MUX_3to1_B U_MUX_3to1_B (
        .X(RD2_r), .Y(Imm32), .Z(Offset), .control(ALUSrcB), .out(B),.rst(rst),.clk(clk),.flush(Flush)
    );

    // ALU
    ALU U_ALU (
        .A(A), .B(B), .ForwardA(ForwardA), .ForwardB(ForwardB), .mem_data(ALU_result_r), .ALUSrcB_EX(ALUSrcB_EX),
        .bubble(bubble), .RD2(RD2_r),
        .wb_data(WD), .ALUOp(ALUOp), .ALU_result(ALU_result), .zero(zero), .real_B_out(real_B)
    );

    Flopr U_ALUOut (
        .clk(clk), .rst(rst), .en(1'b1), .flush(1'b0), .in_data(ALU_result), .out_data(ALU_result_r)
    );
   
    // DM
    DM U_DM (
        .Addr(ALU_result_r[11:2]), .WD(RD2_r), .DMCtrl(DMCtrl), .clk(clk), .RD(RD),.real_B(real_B)
    );


    assign DR_out = RD;
endmodule

