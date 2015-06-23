`timescale 1ns / 1ps
module bin2asc(
    input  [3:0] bin,
	output [7:0] asc
);
	assign asc = bin < 4'd10 ? bin + "0" : bin + ("A" - 8'd10);
endmodule
