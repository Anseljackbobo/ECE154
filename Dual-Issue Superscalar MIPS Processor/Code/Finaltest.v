module datapath_tb;
	reg clk;
	reg reset;
  
	MipsBob dut(clk, reset);

	initial begin
		reset <= 1; #22; reset <= 0;
		#5000;
		$stop;
	end
  
	always begin
		clk <= 1; #5; clk <= 0; #5;
	end
  
  
  
  
endmodule
