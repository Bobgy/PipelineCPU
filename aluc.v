`timescale 1ns / 1ps
module ALUCtrl(
	input [2:0] op,
	input [5:0] sw,
	output [2:0] aluc
);
	wire [2:0] w, u;
	assign w = sw[3] ? (3'b111): (sw[2]?(sw[1:0]):{sw[1], 2'b10});
	assign u = sw[5] ? w : ({sw[1],~sw[1],~sw[1]|sw[0]});
	assign aluc = op[2] ? {2'b0, op[0]} : (op[1] ? (u) : ({op[0], 2'b10}));
endmodule
