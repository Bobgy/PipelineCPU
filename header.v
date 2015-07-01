`timescale 1ns / 1ps
`define ctrl_sig \
InvBranch, ZeroExt, RegDst, Reg31, ALUSrcB,\
MemToReg, WriteReg, MemWrite, Branch,\
Jump

//op
`define R    6'b000_000
`define LW   6'b100_011
`define SW   6'b101_011
`define BEQ  6'b000_100
`define BNE  6'b000_101
`define JMP  6'b000_010
`define ADDI 6'b001_000
`define ANDI 6'b001_100
`define ORI  6'b001_101
//new op
`define ADDIU 6'b001_001
`define XORI  6'b001_110
`define LUI   6'b001_111
`define SLTI  6'b001_010
`define SLTIU 6'b001_011
`define JAL   6'b000_011

//func
`define ADD 6'b100_000
`define SUB 6'b100_010
`define AND 6'b100_100
`define OR  6'b100_101
`define SLL 6'b000_000
`define SRL 6'b000_010
`define SRA 6'b000_011
//new func
`define ADDU 6'b100_001
`define SUBU 6'b100_011
`define XOR  6'b100_110
`define NOR  6'b100_111
`define SLT  6'b101_010
`define SLTU 6'b101_011
`define SLLV 6'b000_100
`define SRLV 6'b000_110
`define SRAV 6'b000_111
`define JR   6'b001_000

`define R_TYPE 0
`define I_TYPE 1
`define J_TYPE 2

//Instruction structure
`define OP 31:26
`define RS 25:21
`define RT 20:16
`define RD 15:11
`define SHAMT 10:6
`define FN     5:0
`define IMMED 15:0

//readRx
`define READ_AT_ID 2'b00
`define READ_AT_EX 2'b01
`define READ_AT_MEM 2'b10
`define READ_NOTHING 2'b11

//ALU operation code
`define ALU_NOP    0
`define ALU_AND    0
`define ALU_OR     1
`define ALU_ADD    2
`define ALU_ADDU   3
`define ALU_SLL    4
`define ALU_SRL    5
`define ALU_SRA    6
`define ALU_SUB    7
`define ALU_SUBU   8
`define ALU_XOR    9
`define ALU_NOR   10
`define ALU_SLT   11
`define ALU_SLTU  12
`define ALU_FUNC  15
