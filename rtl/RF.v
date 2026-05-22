`include "global_def.v"
`include "ctrl_signal_def.v"

module RF(
    input [4:0]  RR1,        // 读取寄存器1地址
    input [4:0]  RR2,        // 读取寄存器2地址
    input [4:0]  WR,         // 写入寄存器地址
    input [31:0] WD,         // 写入数据
    input        RFWrite,    // 写入使能
    input        clk,        // 时钟信号
    output [31:0] RD1,       // 输出数据1
    output [31:0] RD2        // 输出数据2
);

    reg [31:0] register [0:31]; // 32个32位寄存器

    // 初始逻辑：x0 寄存器恒为 0
    initial begin
        register[0] = 32'h0;
    end
    reg [4:0]  WR_EX,WR_MEM,WR_WB;


    Flopr U_WR_ID_EX (.clk(clk), .en(1'b1), .flush(1'b0),.in_data(WR),.out_data(WR_EX));
    Flopr U_WR_EX_MEM (.clk(clk), .en(1'b1), .flush(1'b0),.in_data(WR_EX),.out_data(WR_MEM));
    Flopr U_WR_MEM_WB (.clk(clk), .en(1'b1), .flush(1'b0),.in_data(WR_MEM),.out_data(WR_WB));

    // 写入逻辑：仅在时钟上升沿且满足写入条件时执行
    always @(posedge clk) begin
        
        if ((WR_WB != 0) && (RFWrite == 1)) begin
            register[WR_WB] <= WD; 

            `ifdef DEBUG
                
                $display("R[00-07]=%8X %8X %8X %8X %8X %8X %8X %8X", 0, register[1], register[2], register[3], register[4], register[5], register[6], register[7]);
                $display("R[08-15]=%8X %8X %8X %8X %8X %8X %8X %8X", register[8], register[9], register[10], register[11], register[12], register[13], register[14], register[15]);
                $display("R[16-23]=%8X %8X %8X %8X %8X %8X %8X %8X", register[16], register[17], register[18], register[19], register[20], register[21], register[22], register[23]);
                $display("R[24-31]=%8X %8X %8X %8X %8X %8X %8X %8X", register[24], register[25], register[26], register[27], register[28], register[29], register[30], register[31]);
            `endif
        end
    end

assign RD1 = ((RR1 == WR_WB) && (RFWrite == 1) && (WR_WB != 0)) ? WD : register[RR1];
assign RD2 = ((RR2 == WR_WB) && (RFWrite == 1) && (WR_WB != 0)) ? WD : register[RR2];

endmodule

