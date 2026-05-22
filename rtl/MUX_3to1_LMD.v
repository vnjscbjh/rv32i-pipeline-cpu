`timescale 1ns / 1ps
`include "ctrl_signal_def.v"
module MUX_3to1_LMD(X,Y,Z,control,out,clk,rst);
    input [31:0] X;          //来自ALU的运算结果（通用运算指令）
    input [31:0] Y;          //从数据存储器(DMEM)读出的数据（加载指令 load）
    input [31:0] Z;          //PC自增地址（PC+4，用于跳转链接指令 jal）
    input [1:0]  control;    //写回数据选择控制信号
    input       clk,rst;
    output reg[31:0] out;    //最终送回寄存器堆的数据

    reg  [31:0]  ALU_result_WB;

    Flopr U_ALUOut_MEM_WB (.clk(clk), .rst(rst), .en(1'b1), .flush(1'b0), .in_data(X), .out_data(ALU_result_WB));

    always @ (ALU_result_WB or Y or Z or control)  begin
        case(control)
            `WDSel_FromALU : out = ALU_result_WB;    //选择ALU结果：用于R型/I型算术逻辑指令
            `WDSel_FromMEM : out = Y;    //选择存储器数据：用于加载指令(ld/lb)
            `WDSel_FromPC  : out = Z;    //选择PC+4：用于跳转链接指令(jal)，保存返回地址
            `WDSel_Else    : out = 0;
        endcase
    end
endmodule

