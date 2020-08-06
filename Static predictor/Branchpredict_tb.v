
module Branchpredict_tb();
	reg [15:0] a;
	reg [31:0] b;
	wire y;
	wire [31:0]y2;
	StaticBranchBuffer staticB (a,b,y,y2);

	initial begin
	a <= 16'b 11;
	b <= 32'b 0;
	#15;
	a <= 16'b 100;
	b <= 32'b 1;
	#15;
	end
endmodule