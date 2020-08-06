
module mult_tb();
	reg clk;
	reg start;
	reg is_signed;
	reg reset;
	wire [63:0] s;
	wire isready;
	reg [31:0] a,b;
	
	always begin
		clk <= 1;#5;clk<=0;#5;
	end
	laji_mult dut (a,b, clk,reset, start, is_signed,s, isready);
	initial begin
		start <= 0;
		reset <= 1;
		#10;
		reset <= 0;
		#20;
		a <= 20;
		b <= 30;
		is_signed <= 0;
		start <= 1;
		#10
		start<=0;
		#320;
		start <= 1;
		a <= 24;
		b <= 311;
		is_signed <= 0;
		#10;
		start <= 0;
		#320;
		start <= 1;
		a <= -24;
		b <= 311;
		is_signed <= 0;
		#10;
		start <= 0;
		#320;
		start <= 1;
		a <= -24;
		b <= 311;
		is_signed <= 1;
		#10;
		start <= 0;
		#320;
		start <= 1;
		a <= 311;
		b <= -24;
		is_signed <= 1;
		#10;
		start <= 0;
		#320;
		
		
		$stop;
		
		
	end

	//always begin
	//	clk <= 1;#5;clk<=0;#5;
	//end


endmodule
