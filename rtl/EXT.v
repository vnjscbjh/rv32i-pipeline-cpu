`include "ctrl_signal_def.v"
module EXT(imm_in, ExtSel,out_ins, imm_out);
    input [11:0]      imm_in;       //12位输入立即数
    input             ExtSel;       //扩展选择信号 (0:零扩展, 1:符号扩展)
    input [31:0]      out_ins;
    output reg[31:0]  imm_out;      //32位输出扩展后立即数

// 内部直接提取 opcode 方便 case 判断
    wire [6:0] opcode = out_ins[6:0];

    always @(*) begin
        case (opcode)
            // I-Type: addi, lw 等
            7'b0010011, 7'b0000011,7'b1100111:
                imm_out = {{20{out_ins[31]}}, out_ins[31:20]};

            // S-Type: sw
            7'b0100011:
                imm_out = {{20{out_ins[31]}}, out_ins[31:25], out_ins[11:7]};

            // B-Type: beq
            7'b1100011:
                imm_out = {{19{out_ins[31]}}, out_ins[31], out_ins[7], out_ins[30:25], out_ins[11:8], 1'b0};

            // J-Type: jal
            7'b1101111:
                imm_out = {{11{out_ins[31]}}, out_ins[31], out_ins[19:12], out_ins[20], out_ins[30:21], 1'b0};

            default: imm_out = 32'b0;
        endcase
    end
endmodule

