`timescale 1ns / 1ps

module IR(
    input clk,          
    input IRWrite,          // 写使能信号：用于处理 Stall，拉低时保持当前指令不变
    input rst,
    input [31:0] in_ins,    // 来自指令存储器（IM）的指令
    output  [31:0] out_ins// 传递给译码阶段（ID）的指令
);

assign out_ins = (rst) ? 32'h00000000 :
                 IRWrite       ? in_ins : out_ins;
endmodule


