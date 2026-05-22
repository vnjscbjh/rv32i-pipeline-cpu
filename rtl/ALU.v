`include "ctrl_signal_def.v"
`include "instruction_def.v"
module ALU(A,B,ALUOp,ForwardA,ForwardB,zero,mem_data,wb_data,ALU_result,ALUSrcB_EX,real_B_out,bubble,RD2);
    input   signed [31:0] A;
    input   signed [31:0] B;
    input          [3:0]  ALUOp;
    input          [1:0]  ForwardA; // 2位，因为有 00, 01, 10 三种状态
    input          [1:0]  ForwardB; // 2位
    input          [31:0] mem_data;     // 32位：EX/MEM级的数据
    input          [31:0] wb_data;      // 32位：MEM/WB级的数据
    input          [1:0]  ALUSrcB_EX;
    input                 bubble;
    input          [31:0] RD2;
    output                zero;
    output  reg signed [31:0] ALU_result;
    output      signed [31:0] real_B_out ;
    wire    signed [31:0] real_A;
    wire    signed [31:0] real_B;
    wire    signed [31:0] real_B_plus;
    // 修改后的 ALU 内部选择逻辑
    assign real_A = (bubble == 1'b1) ? 32'b0     : // Stall 触发时强制置零
                    (ForwardA == 2'b01) ? mem_data :
                    (ForwardA == 2'b10) ? wb_data  :
                    A;

    assign real_B = (bubble == 1'b1) ? 32'b0     : // Stall 触发时强制置零
                    (ForwardB == 2'b01) ? mem_data :
                    (ForwardB == 2'b10) ? wb_data  :
                    RD2;

    assign real_B_out = real_B;
    assign real_B_plus = (ALUSrcB_EX == 2'b01) ?   B    :
                                                  real_B;

always @(*) begin
    case(ALUOp)
        // 1. 加法：覆盖add、addi、lw、sw、jal、jalr
        `ALUOp_ADD:  ALU_result = real_A + real_B_plus;

        // 2. 减法：覆盖sub、beq、bne (beq/bne通过A-B判断zero标志)
        `ALUOp_SUB:  ALU_result = real_A - real_B_plus;

        // 3. 按位与：and
        `ALUOp_AND:  ALU_result = real_A & real_B_plus;

        // 4. 按位或：覆盖or、ori
        `ALUOp_OR:   ALU_result = real_A | real_B_plus;

        // 5. 按位异或：xor
        `ALUOp_XOR:  ALU_result = real_A ^ real_B_plus;

        // 6. 逻辑左移sll：移位量取B的低5位 (R型指令shamt为5位，0~31)
        `ALUOp_SLL:  ALU_result = real_A << real_B_plus[4:0];

        // 7. 逻辑右移srl：强制转无符号数右移 (补0)，避免signed默认算术右移
        `ALUOp_SRL:  ALU_result = $unsigned(real_A) >> real_B_plus[4:0];

        // 8. 算术右移sra：signed类型>>>为算术右移 (补符号位)
        `ALUOp_SRA:  ALU_result = real_A >>> real_B_plus[4:0];

        // 默认分支：输出0，避免生成锁存器
        default:     ALU_result = 32'sb0;
    endcase
end


assign zero = (ALU_result == 32'sb0);

endmodule


