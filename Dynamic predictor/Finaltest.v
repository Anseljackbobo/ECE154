module datapath_tb;
	reg clk;
	reg reset;
  
	top dut(clk, reset);
	wire [31:0] pig;
	assign pig = 32'b1;

	wire [31:0] pig2;
	assign pig2 = 32'h800 << 2;
  
	initial begin
		reset <= 1; #22; reset <= 0;
		#5000;
		#5000;
		
		//$display(dut/mip/genius/cs/mem/ram[pig]);
		//$display()
		$stop;
	end
  
	always begin
		clk <= 1; #5; clk <= 0; #5;
	end
  
  
  
  
endmodule
