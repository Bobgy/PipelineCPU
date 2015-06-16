`timescale 1ns / 1ps
//有符号 or 无符号扩展
module Extension(zero, i_16, o_32);
	input zero;
	input[15:0] i_16;
	output[31:0] o_32;
	assign o_32 = {{16{zero ? 1'b0 : i_16[15]}},i_16};
endmodule
