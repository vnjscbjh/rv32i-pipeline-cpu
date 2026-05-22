`include "ctrl_signal_def.v"
`include "instruction_def.v"

module ControlUnit(
    input           clk,            // 时钟
    input           rst,            // 复位
    input           zero,           // ALU零标志 (用于beq/bne)
    input   [6:0]   opcode,         // 指令操作码
    input   [6:0]   Funct7,         // 功能码7
    input   [2:0]   Funct3,         // 功能码3
    //用于冒险检测的输入
    input   [4:0]   rs1,            // 当前 ID 级指令的源寄存器 1
    input   [4:0]   rs2,            // 当前 ID 级指令的源寄存器 2
    input   [4:0]   WR,
    // input   [1:0]   ALUSrcB_r,
    output reg      PCWrite,        // PC写使能
    output reg      IRWrite,        // 指令寄存器写使能
    output reg      InsMemRW,       // 指令存储器读写
    output reg      RFWrite,        // 寄存器写使能
    output reg      DMCtrl,         // 数据存储器控制
    output reg      ExtSel,         // 立即数扩展选择
    output reg      ALUSrcA,        // ALU A口选择
    output reg [1:0] ALUSrcB,       // ALU B口选择
    output reg [1:0] RegSel,        // 写回寄存器选择
    output reg [1:0] NPCop,         // NPC操作选择
    output reg [1:0] WDSel,         // 写回数据选择
    output reg [3:0] ALUop,        // ALU操作码
    //管理流水线的输出
    output reg [1:0] ALUSrcB_EX,
    output reg      Stall,          // 停顿信号
    output reg      Flush,          // 清空信号
    output reg      bubble,
    output reg [1:0] ForwardA, // 2位, 因为有 00, 01, 10 三种状态
    output reg [1:0] ForwardB  // 2位
);
    reg RFWrite_ID,bubble_ID,DMCtrl_ID,DMCtrl_EX,jalr_EX,ALUSrcA_ID,jal,read_EX,Branch1,Branch2,jalr,MemRead;
    reg [4:0]   WR_EX,rs1_EX,rs2_EX,WR_MEM,WR_WB;
    reg RegWrite_MEM,RegWrite_EX,RFWrite_ID;
    reg [1:0]   WDSel_ID,WDSel_EX,WDSel_MEM;
    reg [3:0]   ALUOp_ID;
    //branch,1,2
    Flopr U_Branch1_ID_EX (.clk(clk), .rst(rst), .en(!Stall), .flush(Flush), .in_data(Branch1), .out_data(Branch1_EX));
    Flopr U_Branch2_ID_EX (.clk(clk), .rst(rst), .en(!Stall), .flush(Flush), .in_data(Branch2), .out_data(Branch2_EX));
    Flopr U_jalr_EX (.clk(clk), .rst(rst), .en(!Stall), .flush(Flush), .in_data(jalr), .out_data(jalr_EX));
    //bubble
    Flopr U_bubble_EX (.clk(clk), .rst(rst), .en(1'b1), .flush(Flush), .in_data(bubble_ID), .out_data(bubble));
    //read
    Flopr U_MemRead_ID_EX (.clk(clk), .rst(rst), .en(1'b1), .flush(Flush), .in_data(MemRead), .out_data(read_EX));
    //rs1,2
    Flopr U_rs1_ID_EX (.clk(clk), .rst(rst), .en(1'b1), .flush(Flush), .in_data(rs1), .out_data(rs1_EX));
    Flopr U_rs2_ID_EX (.clk(clk), .rst(rst), .en(1'b1), .flush(Flush), .in_data(rs2), .out_data(rs2_EX));
    //SrcAB
    Flopr U_SrcA_ID_EX (.clk(clk), .rst(rst), .en(1'b1), .flush(Flush), .in_data(ALUSrcA_ID), .out_data(ALUSrcA));
    Flopr U_SrcB_ID_EX (.clk(clk), .rst(rst), .en(1'b1), .flush(Flush), .in_data(ALUSrcB), .out_data(ALUSrcB_EX));
    //DMCtrl
    Flopr U_DMCtrl_ID_EX (.clk(clk), .rst(rst), .en(1'b1), .flush(1'b0), .in_data(DMCtrl_ID), .out_data(DMCtrl_EX));
    Flopr U_DMCtrl_EX_MEM (.clk(clk), .rst(rst), .en(1'b1), .flush(1'b0), .in_data(DMCtrl_EX), .out_data(DMCtrl));
    //ALUOp
    Flopr U_ALUOp_ID_EX (.clk(clk), .rst(rst), .en(1'b1), .flush(Flush), .in_data(ALUOp_ID), .out_data(ALUop));
    //RFWrite
    Flopr U_RW_ID_EX (.clk(clk), .rst(rst), .en(1'b1), .flush((bubble_ID)&& !jal),.in_data(RFWrite_ID),.out_data(RegWrite_EX));
    Flopr U_RW_EX_MEM (.clk(clk), .rst(rst), .en(1'b1), .flush(1'b0),.in_data(RegWrite_EX),.out_data(RegWrite_MEM));
    Flopr U_RW_MEM_WB (.clk(clk), .rst(rst), .en(1'b1), .flush(1'b0),.in_data(RegWrite_MEM),.out_data(RFWrite));
    //WR
    Flopr U_WR_ID_EX (.clk(clk), .rst(rst), .en(1'b1), .flush(1'b0),.in_data(WR),.out_data(WR_EX));
    Flopr U_WR_EX_MEM (.clk(clk), .rst(rst), .en(1'b1), .flush(1'b0),.in_data(WR_EX),.out_data(WR_MEM));
    Flopr U_WR_MEM_WB (.clk(clk), .rst(rst), .en(1'b1), .flush(1'b0),.in_data(WR_MEM),.out_data(WR_WB));
    //WDSel
    Flopr U_WDS_ID_EX (.clk(clk), .rst(rst), .en(1'b1), .flush(1'b0),.in_data(WDSel_ID),.out_data(WDSel_EX));
    Flopr U_WDS_EX_MEM (.clk(clk), .rst(rst), .en(1'b1), .flush(1'b0),.in_data(WDSel_EX),.out_data(WDSel_MEM));
    Flopr U_WDS_MEM_WB (.clk(clk), .rst(rst), .en(1'b1), .flush(1'b0),.in_data(WDSel_MEM),.out_data(WDSel));

always @(*) begin
    // 默认值 (防止产生锁存器)
    PCWrite     = 1'b1;
    IRWrite     = 1'b1;
    MemRead     = 1'b0; // 默认不读内存
    Branch1     = 1'b0; // 默认不跳转
    Branch2     = 1'b0;
    InsMemRW    = 1'b0;
    RFWrite_ID     = 1'b0;
    DMCtrl_ID      = 1'b0;
    ExtSel      = 1'b0;
    ALUSrcA_ID     = 1'b0;
    ALUSrcB     = 2'b00;
    RegSel      = 2'b00;
    NPCop       = `NPC_PC;
    WDSel_ID       = `WDSel_FromALU;
    ALUOp_ID       = `ALUOp_ADD;
    Stall = 1'b0;   // 默认不停顿
    Flush = 1'b0;   // 默认不清空
    ForwardA = 2'b00; // 默认不转发
    ForwardB = 2'b00;
    bubble_ID = 1'b0;
    jalr = 1'b0;
    jal =1'b0;
    // 1. 判定 Stall (优先级最高)
    if (read_EX && (WR_EX != 5'b0) && ((WR_EX == rs1) || (WR_EX == rs2))) begin
        Stall       = 1'b1;
        PCWrite     = 1'b0;
        IRWrite     = 1'b0;
        // 插入气泡
        RFWrite_ID     = 1'b0;
        MemRead     = 1'b0;
        DMCtrl_ID      = 1'b0;
        Flush       = 1'b0; // 停顿时不触发冲刷
        bubble_ID      = 1'b1;
    end
    else if (jalr_EX) begin
        Flush       = 1'b1;
        Stall       = 1'b0;
        PCWrite     = 1'b1;
        IRWrite     = 1'b1;
        bubble_ID      = 1'b1;
        NPCop       = `NPC_rs;
    // NPCop       = `NPC_JALR; // 核心：此时通路必须接 ALU 计算出的基址+偏移地址
    end
    // 2. 判定 Flush (跳转发生)
    else if ((Branch1_EX && zero) || (Branch2_EX && !zero)) begin
        Flush       = 1'b1;     // 触发冲刷信号
        Stall       = 1'b0;
        PCWrite     = 1'b1;     // 允许 PC 更新为跳转目标地址
        IRWrite     = 1'b1;
        bubble_ID      = 1'b1;
        RFWrite_ID     = 1'b0;
        NPCop = `NPC_Offset12;
        // 联动操作：NPC 模块需要根据 Flush 切换地址
        // 此时 NPC 应该输出：Target_PC = beq_pc + offset
    end
    // 4. 判定 JAL 的 Flush (ID级直接触发，实现1拍延迟)
    else if (opcode == `OP_JAL) begin
        Flush       = 1'b1;
        Stall       = 1'b0;
        PCWrite     = 1'b1;
        IRWrite     = 1'b1;
        bubble_ID      = 1'b1;
        RFWrite_ID = 1'b1;
        WDSel_ID   = `WDSel_FromPC;  // 写回PC+4
        NPCop   = `NPC_Offset20; // PC+偏移跳转
    end
    // 3. 正常状态
    else begin
        Flush       = 1'b0;
        Stall       = 1'b0;
        PCWrite     = 1'b1;
        IRWrite     = 1'b1;
        NPCop = `NPC_PC;

    end

    // Forwarding 逻辑
    if (RegWrite_MEM && (WR_MEM != 5'b0) && (WR_MEM == rs1_EX))
        ForwardA = 2'b01; // 来自 EX/MEM 的转发
    else if (RFWrite && (WR_WB != 5'b0) && (WR_WB == rs1_EX))
        ForwardA = 2'b10; // 来自 MEM/WB 的转发
    // ForwardB 判定
    if (RegWrite_MEM && (WR_MEM != 5'b0) && (WR_MEM == rs2_EX))
        ForwardB = 2'b01; // 来自 EX/MEM 的转发
    else if (RFWrite && (WR_WB != 5'b0) && (WR_WB == rs2_EX))
        ForwardB = 2'b10; // 来自 MEM/WB 的转发

case (opcode)
    // ===============================================
    // R 型指令 (寄存器寻址)
    // ===============================================
    `OP_R_TYPE: begin
        RFWrite_ID = 1'b1;   // 写寄存器
        WDSel_ID = `WDSel_FromALU;

        case (Funct3)
            `F3_ADD_SUB: begin
                // 检查 Funct7 的第 5 位 (即 bit 30) , 如果是 1 就是 SUB, 0 就是 ADD
                if (Funct7[5])
                    ALUOp_ID = `ALUOp_SUB;
                else
                    ALUOp_ID = `ALUOp_ADD;
            end
            // `F3_SUB: ALUop = `ALUOp_SUB;a
            `F3_AND: ALUOp_ID = `ALUOp_AND;
            `F3_OR:  ALUOp_ID = `ALUOp_OR;
            `F3_XOR: ALUOp_ID = `ALUOp_XOR;
            `F3_SLL: begin ALUOp_ID = `ALUOp_SLL; ALUSrcA_ID = 1'b0; end
            `F3_SRL_SRA: begin // 这里的宏代表 3'b101
                ALUSrcA_ID = 1'b0; // R 型移位指令通常需要特殊处理寄存器或选通信号
                if (Funct7[5])
                    ALUOp_ID = `ALUOp_SRA; // 赋算术右移的操作码
                else
                    ALUOp_ID = `ALUOp_SRL; // 赋逻辑右移的操作码
            end
            default: ;
            // `F3_SRA: begin ALUop = `ALUOp_SRA; ALUSrcA = 1'b1; end
        endcase
    end

    // ===============================================
    // I 型立即数指令 (立即数寻址)
    // ===============================================
    `OP_I_TYPE: begin
        RFWrite_ID = 1'b1;
        WDSel_ID = `WDSel_FromALU;
        ALUSrcB = 2'b01;   // 选立即数
        ExtSel  = 1'b1;    // 符号扩展

        case (Funct3)
            `F3_ADDI: ALUOp_ID = `ALUOp_ADD;
            `F3_ORI:  begin ALUOp_ID = `ALUOp_OR; ExtSel = 1'b0; end
        endcase
    end

    // ===============================================
    // I 型加载指令 (基址寻址)
    // ===============================================
    `OP_LOAD: begin
        RFWrite_ID = 1'b1;
        ALUSrcB = 2'b01;
        MemRead = 1'b1;
        ExtSel  = 1'b1;
        ALUOp_ID   = `ALUOp_ADD;
        DMCtrl_ID  = 1'b0;   // 读内存
        WDSel_ID   = `WDSel_FromMEM;
    end

    // ===============================================
    // S 型存储指令 (基址寻址)
    // ===============================================
    `OP_STORE: begin

        ALUSrcB = 2'b01;
        ExtSel  = 1'b1;
        ALUOp_ID   = `ALUOp_ADD;
        DMCtrl_ID  = 1'b1;   // 写内存
    end

    // ===============================================
    // B 型分支指令 (PC相对寻址)
    // ===============================================
    `OP_B_TYPE: begin
        ALUSrcB = 2'b00;  // 选寄存器
        ALUOp_ID   = `ALUOp_SUB; // 用 A-B 比较
        RFWrite_ID = 1'b0;
        case (Funct3)
            `F3_BEQ: begin
                Branch1 = 1'b1;
            end

            `F3_BNE: begin
                Branch2 = 1'b1;
            end

            default: begin
            end
        endcase
    end

    // ===============================================
    // J 型跳转指令 (伪直接寻址)
    // ===============================================
    `OP_JAL: begin
        jal = 1'b1;
    end
    //jalr

    `OP_JALR: begin
        RFWrite_ID = 1'b1;           // 写回寄存器 (保存 PC+4)
        WDSel_ID   = `WDSel_FromPC; // 写回内容是 PC+4
        ALUSrcB = 2'b01;         // 选择立即数
        ALUOp_ID   = `ALUOp_ADD;    // ALU 做加法算出目标地址
        //NPCop   = `NPC_rs;       // 告诉 NPC 模块：新 PC = ALU_result
        jalr    = 1'b1;          // 跳转发生, 清空流水线
    end
    default: ;
endcase

end

endmodule
