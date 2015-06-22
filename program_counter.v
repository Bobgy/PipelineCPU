`timescale 1ns / 1ps
module ProgramCounter(clk, rst, i_pc, o_pc);
	parameter N=9;
	input clk, rst;
	input[N-1:0] i_pc;
	output[N-1:0] o_pc;
	reg[N-1:0] t_pc = 0;
	assign o_pc = rst ? {N{1'b1}}:t_pc;
	always @(posedge clk or posedge rst)
		t_pc <= rst ? 0 : i_pc;
endmodule
