`timescale 1ns / 1ps
module RegFile(clk, rst, regA, regB, regW, Wdat, Adat, Bdat, RegWrite, regC, Cdat);
	input clk, rst, RegWrite;
	input [4:0] regA, regB, regW, regC;
	input [31:0] Wdat;
	output [31:0] Adat, Bdat, Cdat;

	reg[31:0] r[31:0];
	reg[5:0] t;
	always @(posedge clk or posedge rst)begin
		if(rst)begin
			for(t=0; t<32; t=t+1)
				r[t]=0;
		end else if(RegWrite)
			r[regW]=Wdat;
	end
	assign Adat=r[regA], Bdat=r[regB];
	assign Cdat=r[regC];
endmodule
