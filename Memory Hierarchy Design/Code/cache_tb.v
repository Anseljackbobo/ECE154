
module cache_tb();
	reg clk, reset; 
	reg [31:0] aluoutm, writedatam; 
	reg memwritem;
	reg enable;
	wire [31:0] mout;
	wire stallm;

	cachesystem dut(clk, reset, aluoutm, writedatam, memwritem, enable, mout,stallm);

	always begin
		clk <= 1;#5;clk<=0;#5;
	end
	initial begin
		reset <= 0;
		#50;
		reset <=1;
		
		#10;
		reset <=0;
		
		#10;
		aluoutm = 32'b 1100000101000;
		writedatam = 32'b 0011;
		memwritem = 1;
		enable = 1;
		#10;
		//enable = 0;
		/*#1000;
		aluoutm = 32'b 1100000101000;
		writedatam = 32'b 1111;
		memwritem = 1;
		//enable = 1;
		#1000;
		aluoutm = 32'b 1100000101100;
		writedatam = 32'b 1111;
		memwritem = 1;
		//enable = 1;
		//#10
		//enable =0;
		#1000
		aluoutm = 32'b 11100000101100;
		writedatam = 32'b 111111;
		memwritem = 1;
		//enable = 1;
		//#10
		//enable =0;
		#1000
		aluoutm = 32'b 1100000101000;
		memwritem = 0;
		//enable = 1;
		#10
		enable = 0;*/
		#10000
		$stop;
	end
endmodule 
