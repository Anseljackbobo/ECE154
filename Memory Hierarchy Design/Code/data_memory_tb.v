module data_memory_tb();
	reg [31:0] address;
	reg [31:0] write_data;
	reg clk;
	reg write;
	wire [31:0] Read_data;
	data_memory dut(clk, write,address, write_data, Read_data);
	always begin
		clk <= 1;#5;clk<=0;#5;
	end
	initial begin
		write <= 0;
		address <= 32'b0011;
		write_data <= 32'b1111;
		#10
		write <= 1;
		address <= 32'b1001;
		write_data <= 32'b1101;
		#10
		write <=0;
		address <= 32'b1101;
		write_data <= 32'b1100;
		#10
		write <=1;
		address <= 32'b0001;
		write_data <= 32'b1010;
		#10
		$stop;
	end
endmodule 

