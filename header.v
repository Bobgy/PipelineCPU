`timescale 1ns / 1ps
`define ctrl_sig ALUop2, InvBranch, ZeroExt, RegDst, ALUSrcB,\
 MemToReg, WriteReg, MemWrite, Branch, ALUop1, ALUop0, Jump

`define R    6'b000_000
`define LW   6'b100_011
`define SW   6'b101_011
`define BEQ  6'b000_100
`define BNE  6'b000_101
`define JMP  6'b000_010
`define ADDI 6'b001_000
`define ANDI 6'b001_100
`define ORI  6'b001_101

`define R_TYPE 0
`define I_TYPE 1
`define J_TYPE 2
