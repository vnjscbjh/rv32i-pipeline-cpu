`include "ctrl_signal_def.v"
module MUX_3to1(X,Y,Z,control,out);
    input [4:0] X;      // 指令rd字段（目标寄存器编号，5位，RISC-V通用寄存器编号0-31）
    input [4:0] Y;      // 指令rt字段（源/目标寄存器编号，5位）
    input [4:0] Z;      // 寄存器31（x31，链接寄存器ra）编号输入（5位，固定为5'b11111）
    input [1:0] control;    // 多路选择控制信号（2位，选择寄存器写地址）
    output reg [4:0] out;   // 寄存器写地址输出（5位，送入寄存器写端口）

always @(X or Y or Z or control) begin
    case(control)
        `RegSel_rd : out = X;      // 选择X：用rd字段作为写地址（普通算术/逻辑指令）
        `RegSel_rt : out = Y;      // 选择Y：用rt字段作为写地址（部分特殊指令）
        `RegSel_31 : out = Z;      // 选择Z：用x31(ra)作为写地址（jal/jalr等跳转链接指令）
        `RegSel_else : out = 0;
    endcase
end

endmodule
