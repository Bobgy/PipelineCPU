`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:55:40 04/07/2015
// Design Name:   alu
// Module Name:   D:/Bobgy/scc/alutest.v
// Project Name:  scc
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: alu
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module alutest;

	// Inputs
	reg [31:0] A;
	reg [31:0] B;
	reg [2:0] op;
	reg [4:0] sa;

	// Outputs
	wire [31:0] res;
	wire o_zf;
	wire [31:0] orAB;

	// Instantiate the Unit Under Test (UUT)
	alu uut (
		.A(A), 
		.B(B), 
		.op(op), 
		.sa(sa), 
		.res(res),
		.o_zf(o_zf)
	);

	initial begin
		// Initialize Inputs
		A = 0;
		B = 0;
		op = 0;
		sa = 0;

		// Wait 100 ns for global reset to finish
		#100;
      A = 0;
		B = 32'h8000_0000;
		op = 3'b101;
		sa = 31;
		// Add stimulus here

	end
      
endmodule

