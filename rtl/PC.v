`timescale 1ns / 1ps
module PC(
    input clk,              // 时钟信号
    input rst,              // 复位信号（高有效，同步复位）
    input PCWrite,          // PC写使能信号（来自ControlUnit）
    input [31:0] NPC,       // 输入：下一条指令地址（来自NPC模块）
    output reg [31:0] PC    // 输出：当前指令地址（送往IM模块取指）
);

// 同步时序逻辑：时钟沿或复位沿触发
always @(posedge clk or posedge rst) begin
    if (rst) begin
        // 复位：初始化PC为起始地址（0x0000_2000, 符合RISC-V默认加载地址）
        PC <= 32'h0000_2000;
    end else if (PCWrite) begin
        // 写使能有效时，更新为下一条地址NPC
        PC <= NPC;
    end
end

endmodule

