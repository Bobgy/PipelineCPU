`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:50:01 06/22/2015
// Design Name:   top
// Module Name:   E:/Programming/courses/ComputerArchitecture/lab2/pipeline/code/test.v
// Project Name:  pipeline
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test;

	// Inputs
	reg CCLK;
	reg [3:0] BTN;
	reg [3:0] SW;

	// Outputs
	wire LCDRS;
	wire LCDRW;
	wire LCDE;
	wire [3:0] LCDDAT;
	wire [7:0] LED;

	// Instantiate the Unit Under Test (UUT)
	top uut (
		.CCLK(CCLK), 
		.BTN(BTN), 
		.SW(SW), 
		.LCDRS(LCDRS), 
		.LCDRW(LCDRW), 
		.LCDE(LCDE), 
		.LCDDAT(LCDDAT), 
		.LED(LED)
	);

	initial begin
		// Initialize Inputs
		CCLK = 0;
		BTN = 0;
		SW = 0;
		BTN[3] = 1;
		
		// Wait 100 ns for global reset to finish
		#470;
      BTN[3] = 0;
		// Add stimulus here

	end
    
	always begin
		#40;
		BTN[2] <= ~BTN[2];
	end
	
endmodule

