`include "ctrl_signal_def.v"
module MUX_3to1_B(X,Y,Z,control,out,rst,clk,flush);
    input [31:0] X;           // 来自寄存器堆或转发路径的 RD2/rs2 数据
    input [31:0] Y;           // 扩展后的 32 位立即数 (Imm)
    input [11:0] Z;           // 12 位偏移量 (Offset)
    input [1:0]  control;     // 多路选择控制信号
    input rst,clk,flush;
    output reg signed [31:0] out; // 选择后的 32 位有符号输出
    reg [11:0] offset_r;
    reg [31:0] Imm;
    reg [1:0]  ALUSrcB_EX;

    Flopr U_IMM_ID_EX (.clk(clk), .rst(rst), .en(1'b1), .flush(Flush), .in_data(Y), .out_data(Imm));

    Flopr U_offset_ID_EX (.clk(clk), .rst(rst), .en(1'b1), .flush(Flush), .in_data(Z), .out_data(Offset_r));

    Flopr U_SrcB_ID_EX (.clk(clk), .rst(rst), .en(1'b1), .flush(Flush), .in_data(control), .out_data(ALUSrcB_EX));

    always @ (X or Imm or offset_r or ALUSrcB_EX)  begin
        case(ALUSrcB_EX)
            `ALUSrcB_B      : out = X;            // 选择 X
            `ALUSrcB_Imm    : out = Imm;            // 选择 Y
            `ALUSrcB_Offset : out = $signed(offset_r);   // 选择 Z 并进行符号扩展
            `ALUSrcB_else   : out = X;            // 默认选择 X
        endcase
    end

endmodule

