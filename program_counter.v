`timescale 1ns / 1ps
module ProgramCounter(clk, rst, lock, i_pc, o_pc);
	parameter N=9;
	input clk, rst, lock;
	input[N-1:0] i_pc;
	output[N-1:0] o_pc;
	reg[N-1:0] t_pc = 0;
	assign o_pc = t_pc;
	always @(posedge clk or posedge rst)
		t_pc <= rst ? {N{1'b1}} : (lock ? t_pc : i_pc);
endmodule
