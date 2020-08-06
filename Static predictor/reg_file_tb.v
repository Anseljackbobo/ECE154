
module reg_file_tb();
	reg clk;
        reg Write;
	reg Reset;
        reg [4:0] PR1, PR2, WR;
        reg [31:0] WD;
        wire [31:0] RD1, RD2;
	always begin
		clk <= 1;#5;clk<=0;#5;
	end
	regfile dut(clk, Write, Reset, PR1, PR2, WR, WD, RD1, RD2);
	initial begin
		Write <= 0;
		Reset <= 1;
		WR <= 5'b01011;
		WD <= 32'b 0010101;
		PR1 <= 5'b01000;
		PR2 <= 5'b01010;
		#10
		Write <= 1;
		Reset <= 0;
		WR <= 5'b01111;
		WD <= 32'b 0010101;
		PR1 <= 5'b01000;
		PR2 <= 5'b01011;
		#10
		Write <= 1;
		Reset <= 0;
		WR <= 5'b01000;
		WD <= 32'b 0010101;
		PR1 <= 5'b01000;
		PR2 <= 5'b01011;
		#10
		Write <= 1;
		Reset <= 1;
		WR <= 5'b01000;
		WD <= 32'b 0010101;
		PR1 <= 5'b01000;
		PR2 <= 5'b01011;
		#10
		$stop;
	end
endmodule
