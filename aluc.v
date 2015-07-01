`timescale 1ns / 1ps
`include "header.v"
module ALUCtrl(
	input [3:0] op,
	input [5:0] fn,
	output reg [3:0] aluc
);
	always @* begin
		if (op==4'hf) begin
			case (fn)
				`ADD  : aluc <= `ALU_ADD;
				`SUB  : aluc <= `ALU_SUB;
				`AND  : aluc <= `ALU_AND;
				`OR   : aluc <= `ALU_OR;
				`SLL  : aluc <= `ALU_SLL;
				`SRL  : aluc <= `ALU_SRL;
				`SRA  : aluc <= `ALU_SRA;
				`ADDU : aluc <= `ALU_ADDU;
				`SUBU : aluc <= `ALU_SUBU;
				`XOR  : aluc <= `ALU_XOR;
				`NOR  : aluc <= `ALU_NOR;
				`SLT  : aluc <= `ALU_SLT;
				`SLTU : aluc <= `ALU_SLTU;
				`SLLV : aluc <= `ALU_SLL;
				`SRLV : aluc <= `ALU_SRL;
				`SRAV : aluc <= `ALU_SRA;
				default : aluc <= 0;
			endcase
		end else aluc <= op;
	end
endmodule
