`timescale 1ns / 1ps
`include "header.v"
module ALU(
	input [31:0] A,
	input [31:0] B,
	input [3:0] op,
	input [4:0] sa, //shift amount
	output [31:0] res,
	output o_zf
);
	reg [31:0] r;
	always @* begin
		case(op)
			`ALU_AND    : r <= A & B;
			`ALU_OR     : r <= A | B;
			`ALU_ADD    : r <= $signed(A) + $signed(B);
			`ALU_ADDU   : r <= A + B;
			`ALU_SLL    : r <= B<<sa;
			`ALU_SRL    : r <= B>>sa;
			`ALU_SRA    : r <= $signed(B)>>>sa;
			`ALU_SUB    : r <= $signed(A) - $signed(B);
			`ALU_SUBU   : r <= A - B;
			`ALU_XOR    : r <= A ^ B;
			`ALU_NOR    : r <= ~ (A | B);
			`ALU_SLT    : r <= $signed(A) < $signed(B);
			`ALU_SLTU   : r <= A < B;
			default     : r <= 0;
		endcase
	end
	assign res = r, o_zf = r == 0;
endmodule
