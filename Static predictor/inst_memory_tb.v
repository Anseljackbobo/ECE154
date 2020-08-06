module inst_memory_tb();
	reg [31:0] address;
	
	wire [31:0] Read_data;
	inst_memory dut(address, Read_data);
	
	initial begin
		#5;
		address <= 32'b0;
		#5;
		address <= 32'b100;
		#5;
		address <= 32'b1000;
		#5;
		
		$stop;
	end	
	
endmodule 


