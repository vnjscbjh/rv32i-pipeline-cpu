module IM(
    input  [9:0]  addr,      // 指令地址（字节地址）
    input         InsMemRW,   // 指令存储器控制信号
    input         clk,
    input         flush,
    input         IRWrite,
    output reg [31:0] Ins         // 输出指令
);

// 定义 1024 个 32 位指令存储单元
reg [31:0] memory [0:1023];
reg halt ;

initial begin
    $readmemh("../hex/code.hex", memory);
   halt <= 1'b0;
end

always @(posedge clk) begin
 
    if(addr == 10'h3fe) begin
        halt <= 1'b1;
    end
    if (flush || halt) begin
        Ins <= 32'h0000_0000;
    end
    else if ( (InsMemRW == 1'b0) && IRWrite) begin
        Ins <=memory[addr[9:0]];
    end
end


endmodule
