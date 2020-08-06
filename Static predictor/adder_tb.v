module adder_tb();
	reg [63:0] a;
	reg [63:0] b;
	wire [63:0] y;
	adder64 adder64b (a,b,y);

	initial begin
	a <= 6'b 1000;
	b <= 6'b 1111;
	#3;
	end
endmodule
