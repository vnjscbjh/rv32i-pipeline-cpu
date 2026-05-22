`timescale 1ns / 1ps
`timescale 1ps / 1ps

module riscv_sim ();
    // Inputs
    reg clk, rst;

    riscv U_RISCV(
        .clk(clk), .rst(rst)
    );

    initial begin
        $readmemh( "../hex/code.hex" ,U_RISCV.U_IM.memory) ;   // 加载指令到存储器
        $display("Instruction memory initialized");
        $monitor("PC = 0x%8X, IR = 0x%8X",U_RISCV.U_PC.PC, U_RISCV.out_ins ); // 实时监控 PC 与指令
        clk = 1 ;
        #5 ;      // 延迟 5ns
        rst = 1 ;
        #20 ;     // 延迟 20ns
        rst = 0 ;
        // ---- 重点：添加这段强制停止逻辑 ----
        #200000;        // 这里的数字代表仿真跑多长时间（根据你的程序长度定）
        $display("Simulation timeout, forcing stop...");
        $finish;         // 这行就是“刹车”，它会让仿真结束并生成最终的波形
    end

    always
        #(50) clk = ~clk; // 生成时钟信号

    initial begin
        $fsdbDumpvars(0,"riscv_sim"); // 生成 FSDB 波形文件
        $fsdbDumpMDA(0,"riscv_sim");  // 生成多维数组（存储器）波形
    end

endmodule  