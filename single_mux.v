`timescale 1ns / 1ps
module single_mux(A, B, Ctrl, S);
	parameter N=1;  // N: 1, 2, 5, 9, 32
	input[N-1:0] A, B;
	input Ctrl;
	output[N-1:0] S;
	assign S = Ctrl ? B : A;
endmodule
