`include "ctrl_signal_def.v"

module Flopr(clk, rst, en, flush, in_data, out_data);
    input           clk;            // 时钟 (原接口不变)
    input           rst;            // 复位 (原接口不变)
    input           en;             
    input           flush;
    input   [31:0]  in_data;        // 输入数据 (原接口不变)
    output reg [31:0] out_data;     // 输出数据 (原接口不变)

always @(posedge clk or posedge rst) begin
    if (rst || flush) begin         // 收到清空信号时，输出清零 (或变为 NOP)
        out_data <= 32'b0;          // 逻辑上等同于插入一个空指令
    end else if (en) begin          // 使能有效且未清空时更新
        out_data <= in_data;
    end
end

endmodule

