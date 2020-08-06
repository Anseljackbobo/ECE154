
module ALU_tb();
	reg clk;
	reg [3:0] Func;
	wire [31:0] ALUout;
	reg [31:0] In1, In2;
	ALU dut(In1, In2, Func, ALUout);
	always begin
		clk <= 1;#5;clk<=0;#5;
	end
	initial begin
		In1 <= 32'b0011;
		In2 <= 32'b1001;
		Func <= 4'b0000;
		#10
		Func <= 4'b0001;
		#10
		Func <= 4'b0010;
		#10
		Func <= 4'b0011;
		#10
		Func <= 4'b0100;
		#10
		Func <= 4'b0101;
		#10
		Func <= 4'b0110;
		#10
		Func <= 4'b0111;
		#10
		In2 <= -32'b1001;
		Func <= 4'b1000;
		#10
		In2 <= -32'b1001;
		Func <= 4'b1001;
		#10

		$stop;
		
	end
endmodule
