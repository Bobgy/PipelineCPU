`timescale 1ns / 1ps
`define ctrl_sig ALUop2, InvBranch, ZeroExt, RegDst, ALUSrcB,\
 MemToReg, WriteReg, MemWrite, Branch, ALUop1, ALUop0, Jump

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

//func
`define ADD 6'b100_000
`define SUB 6'b100_010
`define AND 6'b100_100
`define OR  6'b100_101
`define SLL 6'b000_000
`define SRL 6'b000_010
`define SRA 6'b000_011

`define R_TYPE 0
`define I_TYPE 1
`define J_TYPE 2

//Instruction structure
`define OP 31:26
`define RS 25:21
`define RT 20:16
`define RD 15:11
`define SHAMT 10:6
`define FN 5:0
`define IMMED 15:0

//readRx
`define READ_AT_ID 2'b00
`define READ_AT_EX 2'b01
`define READ_AT_MEM 2'b10
`define READ_NOTHING 2'b11
