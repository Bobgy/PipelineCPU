`timescale 1ns / 1ps
module bin2asc_32(
	input  [31: 0] bin_code,
	output [63: 0] asc_code
);
	bin2asc	b2a0(bin_code[ 3: 0], asc_code[ 7: 0]),
				b2a1(bin_code[ 7: 4], asc_code[15: 8]),
				b2a2(bin_code[11: 8], asc_code[23:16]),
				b2a3(bin_code[15:12], asc_code[31:24]),
				b2a4(bin_code[19:16], asc_code[39:32]),
				b2a5(bin_code[23:20], asc_code[47:40]),
				b2a6(bin_code[27:24], asc_code[55:48]),
				b2a7(bin_code[31:28], asc_code[63:56]);
endmodule
