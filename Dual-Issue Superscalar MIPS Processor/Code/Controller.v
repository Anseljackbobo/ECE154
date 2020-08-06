module Controller (input EqualD, input [5:0] OP,input [5:0] Func, /*input clk,*/ input reset, output MemWrite, /*output jump,*/
	output [1:0] OutSelect, output RegWrite, output ALUSrcB, output Se_ze, output RegDst,
	output Start_mult, output Mult_sign, output MemtoReg, output Eq_ne, output Branch, output [1:0] PCSrcD, output [3:0] ALU_Op,
	output memenable);
	
	reg [17:0] controls;
	wire jump;

	assign {jump,MemWrite, OutSelect, RegWrite, ALUSrcB, Se_ze, RegDst,Start_mult, Mult_sign, MemtoReg, Eq_ne, Branch, ALU_Op, memenable} = controls;
	assign PCSrcD = {jump, (Branch&EqualD)};
	
	always @* begin
		if (reset) begin
		controls <= 18'b0;
		end else begin	
		
		case(OP)
			6'b001000: controls <= 18'b001011100000000100; // addi
			6'b001001: controls <= 18'b001011100000000110; // addiu
			6'b001100: controls <= 18'b001011000000000000; // andi
			6'b001101: controls <= 18'b001011000000000010; // ori
			6'b001110: controls <= 18'b001011000000001100; // xori
			6'b001010: controls <= 18'b001011100000010000; // slti
			6'b001011: controls <= 18'b001011100000010010; // sltiu
			6'b100011: controls <= 18'b001011000010000101; // lw
			6'b101011: controls <= 18'b011001000000000101; // sw
			6'b001111: controls <= 18'b001111000000000000; // lui
			6'b000010: controls <= 18'b100000000000000000; // j
			6'b000101: controls <= 18'b000000100000100000; // bne
			6'b000100: controls <= 18'b000000100001100000; // beq
			default:
				case(Func)
					6'b100000: controls <= 18'b001010010000000100; //add
					6'b100001: controls <= 18'b001010010000000110; //addu
					6'b100010: controls <= 18'b001010010000001000; //sub
					6'b100011: controls <= 18'b001010010000001010; //subu
					6'b100100: controls <= 18'b001010010000000000; //and
					6'b100101: controls <= 18'b001010010000000010; //or
					6'b100110: controls <= 18'b001010010000001100; //xor
					6'b101010: controls <= 18'b001010010000010000; //slt
					6'b101011: controls <= 18'b001010010000010010; //sltu
					6'b011000: controls <= 18'b000000001100000000; //mult
					6'b011001: controls <= 18'b000000001000000000; //multu
					6'b010000: controls <= 18'b000010010000000000; //mfhi
					6'b010010: controls <= 18'b000110010000000000; //mflo
					default: controls <= 18'b001010010000001110; //xnor
				endcase
				
		endcase
		end
	end
				
endmodule



module MainDec (input [5:0] OP, input reset, output RegWrite, output RegDst, output Branch, output memenable, output jump);
	
	reg [4:0] controls;

	assign {RegWrite, RegDst, Branch, memenable, jump} = controls;
	
	always @* begin
		if (reset) begin
		controls <= 4'b0;
		end else begin	
		
		case(OP)
			6'b001000: controls <= 5'b10000; // addi
			6'b001001: controls <= 5'b10000; // addiu
			6'b001100: controls <= 5'b10000; // andi
			6'b001101: controls <= 5'b10000; // ori
			6'b001110: controls <= 5'b10000;// xori
			6'b001010: controls <= 5'b10000; // slti
			6'b001011: controls <= 5'b10000; // sltiu
			6'b100011: controls <= 5'b10010; // lw
			6'b101011: controls <= 5'b00010; // sw
			6'b001111: controls <= 5'b10010; // lui
			6'b000010: controls <= 5'b00001; // j
			6'b000101: controls <= 5'b00100; // bne
			6'b000100: controls <= 5'b00100; // beq
			default:controls <= 5'b11000; //add (Rtype)
				
		endcase
		end
	end
				
endmodule
