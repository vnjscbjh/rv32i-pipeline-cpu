module NPC(
    input  [1:0]   NPCOp,     // NPC控制信号：选择下一条PC的计算方式
    input  [12:1]  Offset12,  // 12位分支偏移 (B型指令beq/bne)
    input  [20:1]  Offset20,  // 20位跳转偏移 (J型指令jal)
    input  [31:0]  PC,        // 当前PC地址
    input          clk,
    input          flush,
    input          stall,
    input  [31:0]  rs,        // 跳转寄存器值 (J型指令jalr)
    input          zero,      // ALU的零标志 (用于beq/bne条件判断)
    input  [31:0]  ALU_result,
    output reg [31:0] PCA4,   // PC+4 (顺序执行地址+跳转指令链接地址)
    output reg [31:0] NPC     // 最终下一条PC地址
);

// 偏移量处理：补0位并转有符号数
wire signed [12:0] Offset13;
wire signed [20:0] Offset21;
reg  [31:0] PCA4_EX,PCA4_IF,PCA4_ID,PCA4_MEM;
reg  [12:1] Offset_EX;
assign Offset13 = $signed({Offset_EX[12:1], 1'b0});
assign Offset21 = $signed({Offset20[20:1], 1'b0});
//offset
Flopr U_offset_ID_EX (.clk(clk), .rst(rst), .en(1'b1), .flush(flush), .in_data(Offset12), .out_data(Offset_EX));
//PCA4
Flopr U_PCA4_IF_ID (.clk(clk), .rst(rst), .en(!stall), .flush(1'b0), .in_data(PCA4_IF), .out_data(PCA4_ID));
Flopr U_PCA4_ID_EX (.clk(clk), .rst(rst), .en(!stall), .flush(1'b0), .in_data(PCA4_ID), .out_data(PCA4_EX));
Flopr U_PCA4_EX_MEM (.clk(clk), .rst(rst), .en(!stall), .flush(1'b0), .in_data(PCA4_EX), .out_data(PCA4_MEM));
Flopr U_PCA4_MEM_WB (.clk(clk), .rst(rst), .en(!stall), .flush(1'b0), .in_data(PCA4_MEM), .out_data(PCA4));

always @(*) begin
    case(NPCOp)
        `NPC_PC       : NPC = PC + 4;                                    
        `NPC_Offset12 : NPC = ($signed({1'b0, PC}) + Offset13 - 8);     
        `NPC_rs       : NPC = ALU_result & 32'hfffffffe;                        
        `NPC_Offset20 : NPC = $signed({1'b0, PC}) + Offset21 - 4;       
        default       : NPC = PC + 4;                                    
    endcase
    PCA4_IF = PC + 4;
end
endmodule

