`timescale 1ns / 1ps
// 指令编码定义
// OPCODE 定义
`define OP_R_TYPE      7'b0110011  // R型指令OPCODE
`define OP_I_TYPE      7'b0010011  // I型指令OPCODE
`define OP_B_TYPE      7'b1100011  // B型指令OPCODE
`define OP_LOAD        7'b0000011  // LW指令OPCODE
`define OP_STORE       7'b0100011  // SW指令OPCODE
`define OP_JAL         7'b1101111  // JAL跳转指令OPCODE
`define OP_JALR        7'b1100111  // JALR寄存器跳转指令OPCODE

// RÀàÐÍ Funct Óò¶šÒå
`define INSTR_ADD_FUNCT     10'b00000000_000   // ADDÖžÁîµÄFunct
`define INSTR_SUB_FUNCT     10'b01000000_000   // SUBÖžÁîµÄFunct
`define INSTR_SUBU_FUNCT    6'b100011          // SUBUÖžÁîµÄFunct
`define INSTR_AND_FUNCT     10'b00000000_111   // ANDÖžÁîµÄFunct
`define INSTR_OR_FUNCT      10'b00000000_110   // ORÖžÁîµÄFunct
`define INSTR_XOR_FUNCT     10'b00000000_100   // XORÖžÁîµÄFunct
`define INSTR_NOR_FUNCT     6'b100111          // NORÖžÁîµÄFunct
`define INSTR_SLL_FUNCT     10'b00000000_001   // SLL£šÂß£×óò¥£©ÖžÁîµÄFunct
`define INSTR_SRL_FUNCT     10'b00000000_101   // SRL£šÂß£Óòò¥£©ÖžÁîµÄFunct
`define INSTR_SRA_FUNCT     10'b01000000_101   // SRA£šÃãÊõÓòò¥£©ÖžÁîµÄFunct
`define INSTR_SRLV_FUNCT    6'b000110          // SRLV£š¿É±äÂß£Óòò¥£©ÖžÁîµÄFunct
`define INSTR_SRAV_FUNCT    6'b000111          // SRAV£š¿É±äÃãÊõÓòò¥£©ÖžÁîµÄFunct
`define INSTR_SLLV_FUNCT    6'b000100          // SLLV£š¿É±äÂß£×óò¥£©ÖžÁîµÄFunct
`define INSTR_JR_FUNCT      6'b001000          // JR£šŒÄŽæ¥÷Ìø×ª£©ÖžÁîµÄFunct

// B型 Funct 定义
`define INSTR_BEQ_FUNCT     3'b000  // BEQ指令Funct
`define INSTR_BNE_FUNCT     3'b001  // BNE指令Funct

// I型 Funct 定义
`define INSTR_ADDI_FUNCT    3'b000  // ADDI指令Funct
`define INSTR_ORI_FUNCT     3'b110  // ORI指令Funct

// ========================================================
// R 型指令特征码 (Funct3)
// ========================================================
`define F3_ADD_SUB  3'b000
`define F3_SLL      3'b001
`define F3_SLT      3'b010
`define F3_SLTU     3'b011
`define F3_XOR      3'b100
`define F3_SRL_SRA  3'b101
`define F3_OR       3'b110
`define F3_AND      3'b111

// ========================================================
// R 型指令特征码 (Funct7) —— 用于区分同 Funct3 的指令
// ========================================================
`define F7_DEFAULT  7'b0000000  // 对应 ADD, SLL, SLT, SLTU, XOR, SRL, OR, AND
`define F7_SUB      7'b0100000  // 专门用于区分 SUB
`define F7_SRA      7'b0100000  // 专门用于区分 SRA

// ========================================================
// B 型指令特征码 (Funct3)
// ========================================================
`define F3_BEQ      3'b000
`define F3_BNE      3'b001

// ========================================================
// I 型立即数指令特征码 (Funct3)
// ========================================================
`define F3_ADDI     3'b000
`define F3_ORI      3'b110