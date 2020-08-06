module delaysignal_tb();
	reg data;
	reg clk;
	reg reset;
	wire out;
	
	signaldelay dut(data, clk, reset, out);
	
	initial begin
		reset <= 0;
		data <= 1;
		#50;
		reset<= 1;
		#10;
		reset <= 0;
		#50;
		data <= 0;
		#50;
		data <= 1;
		#50;
		data<=0;
		#50;
		data<=1;
		#50;
		
		$stop;
	end	

	always begin
		clk <= 1;#5;clk<=0;#5;
	end
	
endmodule 
