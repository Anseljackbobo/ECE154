module controller_tb();
	reg [5:0] OP;
	reg [5:0] Func;  
	//reg clk; 
	reg equald;
	reg reset;
	wire MemWrite; 
	//wire jump;
 	wire [1:0] OutSelect; 
 	wire RegWrite; 
 	wire ALUSrcB; 
 	wire Se_ze; 
 	wire RegDst;
 	wire Start_mult; 
 	wire Mult_sign; 
 	wire MemtoReg; 
 	wire Eq_ne; 
 	wire Branch; 
	wire [1:0] pcsrcd;
 	wire [3:0] ALU_Op;

Controller dut(equald,OP,Func,/*clk,*/reset,MemWrite,/*jump,*/
	OutSelect,RegWrite, ALUSrcB, Se_ze,RegDst,
	Start_mult,Mult_sign, MemtoReg, Eq_ne, Branch, pcsrcd,ALU_Op);
	/*always begin
		clk <= 1;#5;clk<=0;#5;
	end*/
	initial begin
		equald <=0;
		reset <= 0;
		OP <= 6'b001000; //addi
		#10;
		OP <= 6'b001001; //adiu
		#10;
		OP <= 6'b001100; // andi
		#10;
		OP <= 6'b001101; //ori
		#10;
		OP <= 6'b001110;//xori
		#10;
		OP <= 6'b001010;// slti
		#10;
		OP <= 6'b001011;// sltiu
		#10;
		OP <= 6'b100011;// lw
		#10;
		OP <= 6'b101011; //sw
		#10;
		OP <= 6'b001111; //lui
		#10;
		OP <= 6'b000010; //jump
		#10;
		OP <= 6'b000101; //bne
		#10;
		OP <= 6'b000100; //beq
		#10;

		//R type
		OP <= 6'b0;
		Func <= 6'b100000;//add
		#10;
		Func <= 6'b100001;//addu
		#10;
		Func <= 6'b011000;//mult
		#10;
		Func <= 6'b011001;//multu
		#10;
		
		

		$stop;
		
	end
endmodule
