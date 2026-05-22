`include "ctrl_signal_def.v"
module MUX_2to1_A(X,Y,control,out);
    input [31:0] X;           // 输入X (32位)
    input [4:0]  Y;           // 输入Y (5位)
    input        control;     // 选择控制信号
    output [31:0] out;        // 输出 (32位)

    assign out = (control == 1'b0 ? X : {27'b0,Y[4:0]});

endmodule
